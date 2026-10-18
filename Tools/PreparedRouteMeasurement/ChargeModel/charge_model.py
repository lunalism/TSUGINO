#!/usr/bin/env python3
"""Analysis tooling: arithmetic replica of the InternalRouteSolver meter charges.

This is NOT TSUGINO execution, profiling or measurement. It recomputes the solver's logical
work credits from the charge formulas in TSUGINO/Data/Routing/InternalRouteSolver.swift and the
§30.4 invented generators (TSUGINOTests/Support/PreparedRouteWorkloads.swift,
InternalSolverFixtures.swift). P's inherited payload (`preparedBytes`) comes from the committed
§31 results.json. Variants:

  insertion  solver before 9accdea (insertion-sort ordering) — compared with the §31 records
  merge      published solver at 9accdea (metered merge sort) — compared with WinnerOrdering records
  index      merge + the consumer §34 per-ride feasible-relation lists (a design, not implemented)

Usage:
  python3 -B -I Tools/PreparedRouteMeasurement/ChargeModel/charge_model.py validate
  python3 -B -I Tools/PreparedRouteMeasurement/ChargeModel/charge_model.py index
"""
import decimal
import json
import pathlib
import sys
from dataclasses import dataclass

HERE = pathlib.Path(__file__).resolve().parent
S31 = HERE.parent / 'results.json'
S33 = HERE.parent / 'WinnerOrdering' / 'results.json'
DAY = 'invented-day'
CEILING = 100_000_000


class Cutoff(Exception):
    pass


@dataclass
class Ride:
    trip: str
    frm: str
    to: str
    arr: float
    day: str = DAY
    stops: int = 2
    b: int = 0
    a: int = 1


@dataclass
class Conn:
    f: int
    t: int
    state: str = 'feasible'
    alight: int = 1
    board: int = 0


class Kernel:
    """One invocation's meter and trace. `charge` mirrors InternalSolverMeter.charge's work
    dimension, including the default work 1 of slot/byte-only charges."""

    def __init__(self, rides, conns, payload, stations, trips, variant, max_rides=7, max_work=CEILING, lines=1):
        self.rides, self.conns, self.payload = rides, conns, payload
        self.stations, self.trips, self.lines = stations, trips, lines
        self.variant, self.max_rides, self.max_work = variant, max_rides, max_work
        self.work, self.stage, self.cur, self.calls = 0, {}, '', 0
        self.ops, self.entries, self.counts = {}, [], {}

    def charge(self, w=1, tag='unit'):
        if w > self.max_work - self.work:
            raise Cutoff(self.cur)
        self.calls += 1  # charge calls: the §32.4 runtime proxy
        self.work += w
        self.stage[self.cur] = self.stage.get(self.cur, 0) + w
        self.ops[(self.cur, tag)] = self.ops.get((self.cur, tag), 0) + w

    def count(self, tag, n=1):
        self.counts[tag] = self.counts.get(tag, 0) + n

    def enter(self, s):
        self.cur = s
        self.charge(1, 'enter')
        self.entries.append((s, self.work))

    def key(self, i):
        return (self.rides[i].trip, self.rides[i].day)

    def snap(self, i):
        return 4096 * (self.rides[i].stops + 1)

    def relation(self, x, y, tag):
        """`relation(_:)`: linear scan, 4096 per inspected relation, first equal key."""
        want = (self.key(x), self.rides[x].a, self.key(y), self.rides[y].b)
        for i, c in enumerate(self.conns):
            self.charge(4096, tag)
            self.count(tag)
            if (self.key(c.f), c.alight, self.key(c.t), c.board) == want:
                return i
        return None

    def less(self, l, r):
        for a, b in zip(l, r):
            self.charge(1, 'compare')
            if a == b:
                continue
            self.charge(1, 'compareScratch')
            x, y = self.rides[a], self.rides[b]
            for lb, rb in [(b'\0' * 16, b'\0' * 16), (x.trip.encode(), y.trip.encode()), (x.day.encode(), y.day.encode())]:
                for p, q in zip(lb, rb):
                    self.charge(1, 'compareByte')
                    if p != q:
                        return p < q
                if len(lb) != len(rb):
                    return len(lb) < len(rb)
            if x.b != y.b:
                return x.b < y.b
            if x.a != y.a:
                return x.a < y.a
        return len(l) < len(r)

    def order(self, winners):
        n = len(winners)
        if self.variant == 'insertion':
            for i in range(1, n):
                j = i
                while j > 0:
                    self.charge(1, 'sortStep')
                    if not self.less(winners[j], winners[j - 1]):
                        break
                    self.charge(1, 'swap')
                    winners[j], winners[j - 1] = winners[j - 1], winners[j]
                    j -= 1
            return winners
        self.charge(1, 'preflight')
        order, width = list(range(n)), 1
        while width < n:
            out = []
            for low in range(0, n, 2 * width):
                a, b = order[low:low + width], order[low + width:low + 2 * width]
                i = j = 0
                while i < len(a) and j < len(b):
                    self.charge(1, 'sortStep')
                    if self.less(winners[b[j]], winners[a[i]]):
                        out.append(b[j]); j += 1
                    else:
                        out.append(a[i]); i += 1
                    self.charge(1, 'move')
                for x in a[i:] + b[j:]:
                    self.charge(1, 'move'); out.append(x)
            order, width = out, width * 2
        for _ in order:
            self.charge(1, 'copy')
        return [winners[k] for k in order]

    def build_index(self):
        """§34 design: one relation-major pass over feasible relations and all rides, 4096 per
        (relation, ride) pair (one full key-equivalent comparison of both endpoints), with every
        list entry charged before it is appended. Lists are ascending by construction."""
        P = len(self.rides)
        self.charge(1, 'indexPreflight')        # 2P empty list headers
        out_rel, in_rel = [[] for _ in range(P)], [[] for _ in range(P)]
        for r, c in enumerate(self.conns):
            self.charge(1, 'indexState')
            if c.state != 'feasible':
                continue
            for z, ride in enumerate(self.rides):
                self.charge(4096, 'indexPair')
                self.count('indexPair')
                if self.key(c.f) == self.key(z) and c.alight == ride.a:
                    self.charge(1, 'indexEntry'); out_rel[z].append(r); self.count('indexEntry')
                if self.key(c.t) == self.key(z) and c.board == ride.b:
                    self.charge(1, 'indexEntry'); in_rel[z].append(r); self.count('indexEntry')
        return out_rel, in_rel

    def accepted(self, x, y, out_rel, in_rel):
        """§34 lookup: 1 per lookup plus 1 per ascending-merge step; keys are unique, so the
        intersection holds at most one relation."""
        self.charge(1, 'lookup')
        self.count('lookup')
        o, i_, p, q = out_rel[x], in_rel[y], 0, 0
        while p < len(o) and q < len(i_):
            self.charge(1, 'mergeStep')
            self.count('mergeStep')
            if o[p] == i_[q]:
                return True
            if o[p] < i_[q]:
                p += 1
            else:
                q += 1
        return False

    def run(self):
        P = len(self.rides)
        try:
            self.enter('indexing')
            self.charge(self.payload, 'payload')
            self.charge(1, 'storage')
            outgoing = []
            out_rel = in_rel = None
            for i, r in enumerate(self.rides):
                self.charge(self.snap(i), 'snapshot')
                if self.variant != 'index':
                    ok = False
                    for c in self.conns:
                        self.charge(4096, 'outgoingScan')
                        if c.state == 'feasible' and self.key(c.f) == self.key(i) and c.alight == r.a:
                            ok = True
                            break
                    outgoing.append(ok)
                self.charge(16 + len(r.trip.encode()) + len(r.day.encode()), 'orderKey')
            for _ in self.conns:
                self.charge(4096, 'evidenceCheck')
            if self.variant == 'index':
                out_rel, in_rel = self.build_index()
                outgoing = [bool(o) for o in out_rel]
            self.enter('exploration')
            bound = min(self.max_rides, P)
            path, nxt, winners, best, bestc = [], [0], [], None, 0
            self.charge(1, 'storage')
            while nxt:
                self.charge(1, 'loop')
                if nxt[-1] == P:
                    nxt.pop()
                    if path:
                        path.pop()
                    continue
                cand = nxt[-1]
                nxt[-1] += 1
                r = self.rides[cand]
                self.charge(4096, 'candidate')
                self.count('candidate')
                if not path:
                    if r.frm != 'O':
                        continue
                else:
                    if any(self._repeat(prev, r) for prev in path):
                        continue
                    if self.variant == 'index':
                        if not self.accepted(path[-1], cand, out_rel, in_rel):
                            continue
                    else:
                        e = self.relation(path[-1], cand, 'dfsRelation')
                        if e is None or self.conns[e].state != 'feasible':
                            continue
                if len(path) >= bound:
                    continue
                self.charge(len(path) + 1, 'pathAppend')
                path.append(cand)
                self.count('node')
                if r.to == 'D':
                    self.enter('tieCollection')
                    self.cur = 'exploration'
                    if best is None or r.arr < best or (r.arr == best and len(path) < bestc):
                        best, bestc, winners = r.arr, len(path), []
                    if r.arr == best and len(path) == bestc:
                        dup = False
                        for w in winners:
                            self.charge(len(w) + 1, 'dedup')
                            if w == path:
                                dup = True
                                break
                        if not dup:
                            if len(winners) >= 256:
                                raise Cutoff('tieCollection (winner cap)')
                            self.charge(len(path), 'winnerAppend')
                            winners.append(list(path))
                if len(path) < bound and outgoing[cand]:
                    self.charge(1, 'storage')
                    nxt.append(0)
                else:
                    path.pop()
            self.enter('ordering')
            winners = self.order(winners)
            self.enter('admission')
            self.charge(1, 'storage')
            for w in winners:
                self.enter('admission')
                n = len(w)
                self.charge(n, 'claim')
                for t in w:
                    self.charge(self.snap(t), 'claimSnapshot')
                for x, y in zip(w, w[1:]):
                    self.relation(x, y, 'claimRelation')
                self.charge(max(1, n) * 4096, 'admitBase')
                self.charge(1, 'storage')
                for x, y in zip(w, w[1:]):
                    self.relation(x, y, 'admitRelation')
                for i in range(n):
                    for _ in range(i):
                        self.charge(1024, 'admitTripPairs')
                for t in w:
                    self.charge(self.snap(t), 'admitSnapshot')
                for _ in w:
                    self.charge(1, 'admitTime')
                for _ in w[1:]:
                    self.charge(1, 'admitEdge')
                self.charge(1, 'storage')
                for t in w:
                    self.charge(self.snap(t), 'legSnapshot')
                self.charge(n * n * 1024, 'admitPairs')
                self.charge(1, 'storage')
            self.enter('finalization')
            for w in winners:
                for t in w:
                    member = (self.stations * self.rides[t].stops + self.lines + self.trips) * 1024
                    self.charge(self.snap(t) + member, 'finalValidation')
            self.charge(1, 'storage')
            self.charge(len(winners) + 1, 'finalOutput')
            self.enter('terminal')
            return 'C', winners
        except Cutoff as c:
            return 'I-solver', str(c)

    def _repeat(self, prev, r):
        self.charge(1024, 'tripRepeat')
        return self.rides[prev].trip == r.trip


# MARK: §30.4 generators (structure only)

def pad(p, n, w):
    return p + str(n).rjust(w, '0')


def w1(k):
    names = [pad('d-', i, 4) for i in range(k)][::-1]
    return [Ride(n, 'O', 'D', 1010) for n in names], [], dict(stations=2, trips=k)


def layered(prefixes, width, stations, state=lambda n: 'feasible'):
    layers = [[pad(p + '-', i, 3) for i in range(width)] for p in prefixes]
    by = {}
    for j, names in enumerate(layers):
        for n in names:
            by[n] = Ride(n, stations[j], stations[j + 1], 1010 + 20 * j)
    order = sorted(by)[::-1]
    idx = {n: i for i, n in enumerate(order)}
    conns, k = [], 0
    for j in range(len(layers) - 1):
        for f in layers[j]:
            for t in layers[j + 1]:
                conns.append(Conn(idx[f], idx[t], state(k)))
                k += 1
    return [by[n] for n in order], conns


def w2a(w):
    rides, conns = layered(['A', 'B'], w, ['O', 'H', 'D'])
    return rides, conns, dict(stations=3, trips=len(rides))


def w2b(d):
    stations = ['O'] + [pad('H', i, 2) for i in range(1, d)] + ['D']
    rides, conns = layered([pad('L', i, 2) for i in range(d)], 2, stations)
    return rides, conns, dict(stations=len(stations), trips=len(rides), max_rides=8)


def w3mask(pct):
    m, state, idx = (1 << 64) - 1, 0x5453_5547_494E_4F00 + pct, list(range(72))
    for i in range(71, 0, -1):
        state = (state + 0x9E3779B97F4A7C15) & m
        z = state
        z = ((z ^ (z >> 30)) * 0xBF58476D1CE4E5B9) & m
        z = ((z ^ (z >> 27)) * 0x94D049BB133111EB) & m
        z ^= z >> 31
        j = z % (i + 1)
        idx[i], idx[j] = idx[j], idx[i]
    count = int(decimal.Decimal(pct * 72 / 100).quantize(0, rounding=decimal.ROUND_HALF_UP))
    return set(idx[:count])


def w3(pct, absent=False):
    mask = w3mask(pct)
    other = 'absent' if absent else 'infeasible'
    rides, conns = layered(['A', 'B', 'C'], 6, ['O', 'H1', 'H2', 'D'], lambda n: 'feasible' if n in mask else other)
    return rides, conns, dict(stations=4, trips=len(rides))


def w5(m):
    rides = []
    for i in range(m):
        rides.append(Ride(pad('out-', i, 2), 'O', pad('A', i, 2), 1000))
        rides.append(Ride(pad('back-', i, 2), pad('A', i, 2), 'O', 1000))
    rides.append(Ride('direct', 'O', 'D', 1000))
    d, conns = len(rides) - 1, []
    for i in range(m):
        conns.append(Conn(2 * i, 2 * i + 1))
        conns += [Conn(2 * i + 1, 2 * j) for j in range(m)]
        conns.append(Conn(2 * i + 1, d))
    return rides, conns, dict(stations=m + 2, trips=len(rides))


def cases():
    out = {}
    for k in [1, 2, 8, 32, 64, 128, 256, 257]:
        out[pad('W1-', k, 4)] = (w1(k), CEILING)
    for w in [2, 3, 4, 6, 8, 9, 10, 11]:
        out[pad('W2a-', w, 2)] = (w2a(w), CEILING)
    for d in range(2, 8):
        out[f'W2b-{d}'] = (w2b(d), CEILING)
    for p in [0, 10, 25, 50, 100]:
        out[pad('W3-', p, 3)] = (w3(p), CEILING)
    out['W3a-010'] = (w3(10, True), CEILING)
    for m in range(1, 6):
        out[f'W5-{m}'] = (w5(m), CEILING)
    for mw in [1, 4, 16, 64]:
        out[pad('W8-', mw, 3) + 'M'] = (w2a(8), mw * 1_000_000)
    return out


def payloads():
    data = json.loads(S31.read_text())
    disc = {r['caseID']: r for r in data['records'] if r.get('pass') == 'discovery' and r.get('kind') == 'sample'}
    pay = {c: (r.get('structural') or {}).get('preparedBytes') for c, r in disc.items()}
    for mw in [1, 4, 16, 64]:
        pay[pad('W8-', mw, 3) + 'M'] = pay['W2a-08']
    return disc, pay


def kernel(case, variant, pay, max_work=None):
    (rides, conns, extra), ceiling = cases()[case]
    extra = dict(extra)
    return Kernel(rides, conns, pay[case], extra.pop('stations'), extra.pop('trips'), variant,
                  max_work=max_work or ceiling, **extra)


def last_observation(k):
    return k.entries[-1] if k.entries else (None, None)


def validate():
    disc, pay = payloads()
    ok = 0
    for case in cases():
        k = kernel(case, 'insertion', pay)
        cls, _ = k.run()
        stage, work = last_observation(k)
        u = disc[case]['solverUsage']
        match = (cls == disc[case]['class'] or (cls == 'I-solver' and disc[case]['class'] == 'I-solver')) \
            and stage == u['observedAt'] and work == u['work']
        ok += match
        print(f"{case:9} §31 {disc[case]['class']:8} {u['work']:>10} @{u['observedAt']:13} model {cls:8} {work:>10} @{stage:13} {'MATCH' if match else 'DIFF'}")
    print(f'insertion vs §31: {ok}/{len(cases())} exact')
    s33 = json.loads(S33.read_text())
    ok33 = n33 = 0
    for r in s33['records']:
        if r.get('pass') == 'discovery' and r.get('kind') == 'sample' and r.get('tree') == 'optimized':
            k = kernel(r['caseID'], 'merge', pay)
            k.run()
            stage, work = last_observation(k)
            n33 += 1
            ok33 += stage == r['solverUsage']['observedAt'] and work == r['solverUsage']['work']
    print(f'merge vs WinnerOrdering optimized discovery: {ok33}/{n33} exact')


def summary(k):
    rel = sum(v for (s, t), v in k.ops.items() if t in ('dfsRelation', 'claimRelation', 'admitRelation', 'outgoingScan', 'indexPair'))
    return rel


def index_report():
    disc, pay = payloads()
    rows = []
    print('| Case | §31 class | merge: class @ stage | merge credits | index: class @ stage | index credits | credits to complete (merge → index) | index pairs | entries | lookups | merge steps | calls at 100M (merge → index) | calls to complete (merge → index) |')
    print('|---|---|---|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|')
    for case in cases():
        m, i = kernel(case, 'merge', pay), kernel(case, 'index', pay)
        cm, im = m.run(), i.run()
        fm, fi = kernel(case, 'merge', pay, 10**13), kernel(case, 'index', pay, 10**13)
        fm.run(); fi.run()
        sm, si = last_observation(m), last_observation(i)
        row = dict(case=case, s31=disc[case]['class'], merge=[cm[0], sm[0], m.work], index=[im[0], si[0], i.work],
                   completeMerge=fm.work, completeIndex=fi.work, counts=fi.counts,
                   calls=[m.calls, i.calls], callsComplete=[fm.calls, fi.calls],
                   stagesIndex={k: v for k, v in fi.stage.items()}, stagesMerge={k: v for k, v in fm.stage.items()})
        rows.append(row)
        c = fi.counts
        print(f"| {case} | {row['s31']} | {cm[0]} @ {sm[0]} | {m.work:,} | {im[0]} @ {si[0]} | {i.work:,} | "
              f"{fm.work / 1e6:.2f}M → {fi.work / 1e6:.2f}M | {c.get('indexPair', 0):,} | {c.get('indexEntry', 0):,} | "
              f"{c.get('lookup', 0):,} | {c.get('mergeStep', 0):,} | {m.calls:,} → {i.calls:,} ({i.calls / m.calls:.3f}) | "
              f"{fm.calls:,} → {fi.calls:,} ({fi.calls / fm.calls:.3f}) |")
    return rows


if __name__ == '__main__':
    command = sys.argv[1] if len(sys.argv) > 1 else ''
    if command == 'validate':
        validate()
    elif command == 'index':
        rows = index_report()
        if len(sys.argv) > 2:
            pathlib.Path(sys.argv[2]).write_text(json.dumps(rows, indent=1, sort_keys=True) + '\n')
    else:
        raise SystemExit(__doc__)
