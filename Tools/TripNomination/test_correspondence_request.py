"""Invented correspondence fixtures and private temporary files only."""
import copy
import hashlib
import json
import os
from pathlib import Path
import stat
import subprocess
import sys
import tempfile
import unittest
from unittest import mock

import correspondence_request as c


def fixtures():
    source = dict(sourceID='invented.feed', namespace='gtfs.trip_id', key='invented-private-é-東京',
                  profileID='invented-profile', profileVersion='invented-v1', inputSHA256='a' * 64,
                  publisherID='invented-publisher', resourceID='invented-resource', feedRevision='invented-r1')
    baseline = dict(lineageID='invented-lineage', schemaVersion=2, revision=6, registrySHA256='b' * 64)
    mapping = dict(version='invented-mapping-v1', sha256='c' * 64)
    evidence = [dict(role=role, evidenceID='invented-' + role,
                     sha256=hashlib.sha256(role.encode()).hexdigest(), locator='invented-locator-' + role,
                     source=copy.deepcopy(source), baseline=copy.deepcopy(baseline), mapping=copy.deepcopy(mapping))
                for role in sorted(c.ROLES)]
    context = dict(format=c.CONTEXT_FORMAT, schemaVersion=1, ownerAuthority='invented-owner',
                   source=source, baseline=baseline, mapping=mapping, evidence=evidence)
    conclusion = dict(distinctNewRunRequested=True, existingCanonicalTripTarget=None,
                      priorCanonicalTripBinding='noneStructurallyPossibleInPriorBaseline',
                      acceptedCanonicalCompetitors='noneStructurallyPossibleInPriorBaseline',
                      externalSemanticCompetition='notGloballyDisproved', semanticDistinctnessFromAllSourceRows=False,
                      affirmativeReasoning='Invented reviewed source semantics support one scoped recurring run; '
                                           'classification and structure do not themselves establish identity.',
                      basisEvidenceIDs=['invented-sourceProfileAcceptance', 'invented-candidateApplicability'])
    payload = dict(requestID='invented-request', ownerAuthority='invented-owner', mode='distinctNewRun',
                   source=copy.deepcopy(source), baseline=copy.deepcopy(baseline), mapping=copy.deepcopy(mapping),
                   baselineCapability='noTripIdentityStateInIdentifiedBaseline', evidence=copy.deepcopy(evidence),
                   conclusion=conclusion, unresolvedPrerequisites=sorted(c.PREREQUISITES))
    return payload, context


class RepresentationTests(unittest.TestCase):
    def setUp(self):
        self.payload, self.context = fixtures()
        self.proposal = c.prepare(self.payload, self.context)

    def approved(self, proposal=None, context=None):
        p = proposal or self.proposal
        return c.approve(p, context or self.context, c.proposal_digest(p['payload']),
                         'invented-owner', '2026-10-08T12:34:56Z', c.CONFIRMATION)

    def rejected(self, function, *args):
        with self.assertRaises(c.RequestError) as caught:
            function(*args)
        self.assertNotIn(self.payload['source']['key'], str(caught.exception))
        return str(caught.exception)

    def test_valid_proposal_is_unapproved_and_cannot_verify(self):
        self.assertIsNone(self.proposal['approval'])
        self.assertEqual(c.validate(self.proposal, self.context), self.proposal)
        self.assertEqual(self.rejected(c.validate, self.proposal, self.context, True), 'approvalRequired')
        self.assertEqual(c.summary(self.proposal)['status'], 'unapprovedProposal')

    def test_valid_explicit_approval(self):
        approved = self.approved()
        self.assertEqual(c.validate(approved, self.context, True), approved)
        self.assertEqual(approved['approval']['authorityID'], 'invented-owner')
        self.assertEqual(approved['approval']['proposalSHA256'], c.proposal_digest(self.proposal['payload']))
        self.assertEqual(approved['approval']['approvedContentSHA256'], c.approved_digest(approved['payload'], approved['approval']))
        self.assertFalse(c.summary(approved)['registrationAuthorized'])
        self.assertFalse(c.summary(approved)['s9Accepted'])

    def test_returned_records_do_not_alias_proposal_or_inputs(self):
        before = c.canonical(self.proposal), c.canonical(self.payload), c.canonical(self.context)
        approved = self.approved()
        approved['payload']['source']['key'] = 'invented-edited-result'
        approved['payload']['evidence'][0]['locator'] = 'invented-edited-locator'
        self.assertEqual(before, (c.canonical(self.proposal), c.canonical(self.payload), c.canonical(self.context)))

    def test_approval_requires_exact_digest_and_explicit_action(self):
        self.rejected(c.approve, self.proposal, self.context, 'd' * 64, 'invented-owner', '2026-10-08T12:34:56Z', c.CONFIRMATION)
        self.rejected(c.approve, self.proposal, self.context, c.proposal_digest(self.payload),
                      'invented-owner', '2026-10-08T12:34:56Z', None)
        self.rejected(c.approve, self.approved(), self.context, c.proposal_digest(self.payload),
                      'invented-owner', '2026-10-08T12:34:56Z', c.CONFIRMATION)

    def test_exact_digest_domains(self):
        payload = self.proposal['payload']
        canonical = json.dumps(dict(domain=c.FORMAT + '/proposal/v1', format=c.FORMAT, schemaVersion=1, payload=payload),
                               ensure_ascii=False, sort_keys=True, separators=(',', ':')).encode('utf-8')
        self.assertEqual(c.proposal_digest(payload), hashlib.sha256(canonical).hexdigest())
        approved = self.approved()
        metadata = {k: approved['approval'][k] for k in ('authorityID', 'approvedAt', 'proposalSHA256')}
        canonical = json.dumps(dict(domain=c.FORMAT + '/approval/v1', format=c.FORMAT, schemaVersion=1,
                                    payload=payload, ownerApproval=metadata),
                               ensure_ascii=False, sort_keys=True, separators=(',', ':')).encode('utf-8')
        self.assertEqual(approved['approval']['approvedContentSHA256'], hashlib.sha256(canonical).hexdigest())

    def test_reordered_json_and_set_lists_canonicalize(self):
        raw = json.dumps(self.proposal, indent=4, ensure_ascii=True).encode()
        reordered = c.decode(raw)
        reordered['payload']['evidence'].reverse()
        reordered['payload']['unresolvedPrerequisites'].reverse()
        reordered['payload']['conclusion']['basisEvidenceIDs'].reverse()
        reordered = {k: reordered[k] for k in reversed(list(reordered))}
        self.assertEqual(c.canonical(c.validate(reordered, self.context)), c.canonical(self.proposal))
        self.assertEqual(c.proposal_digest(c.validate(reordered, self.context)['payload']), c.proposal_digest(self.proposal['payload']))

    def test_unchanged_rerun_identical_proposal_and_approval(self):
        again = c.prepare(copy.deepcopy(self.payload), copy.deepcopy(self.context))
        self.assertEqual(c.canonical(again), c.canonical(self.proposal))
        self.assertEqual(c.canonical(self.approved(again)), c.canonical(self.approved()))

    def test_scalar_preservation_and_normalization_distinctions(self):
        digests = []
        for key in ('invented-é', 'invented-e\u0301', 'invented-東京-한글-\\-\n-\u202e-\x00'):
            with self.subTest(key=repr(key)):
                payload, context = fixtures()
                for value in (payload['source'], context['source']):
                    value['key'] = key
                for evidence in (payload['evidence'], context['evidence']):
                    for item in evidence:
                        item['source']['key'] = key
                prepared = c.prepare(payload, context)
                decoded = c.decode(c.canonical(prepared))
                self.assertEqual(decoded['payload']['source']['key'], key)
                digests.append(c.proposal_digest(prepared['payload']))
        self.assertEqual(len(set(digests)), 3)

    def test_source_key_mutation_after_approval_rejected_even_with_rebound_context(self):
        approved = self.approved()
        approved['payload']['source']['key'] = 'invented-other'
        context = copy.deepcopy(self.context)
        context['source']['key'] = 'invented-other'
        for inventory in (approved['payload']['evidence'], context['evidence']):
            for evidence in inventory:
                evidence['source']['key'] = 'invented-other'
        self.assertEqual(self.rejected(c.validate, approved, context, True), 'approvalDigestMismatch')

    def test_source_profile_input_mapping_mutations_break_approval(self):
        for group, name, replacement in (('source', 'profileID', 'invented-other'), ('source', 'profileVersion', 'invented-v2'),
                                         ('source', 'inputSHA256', 'd' * 64), ('source', 'feedRevision', 'invented-r2'),
                                         ('source', 'sourceID', 'invented-other'), ('mapping', 'version', 'invented-v2'),
                                         ('mapping', 'sha256', 'd' * 64)):
            with self.subTest(group=group, name=name):
                approved = self.approved()
                context = copy.deepcopy(self.context)
                for value in (approved['payload'][group], context[group]):
                    value[name] = replacement
                for inventory in (approved['payload']['evidence'], context['evidence']):
                    for evidence in inventory:
                        evidence[group][name] = replacement
                self.assertEqual(self.rejected(c.validate, approved, context, True), 'approvalDigestMismatch')

    def test_wrong_checkpoint_and_changed_revision_rejected(self):
        for field, value in (('registrySHA256', 'd' * 64), ('lineageID', 'invented-other'),
                             ('revision', 7), ('schemaVersion', 3), ('revision', True), ('schemaVersion', True)):
            with self.subTest(field=field):
                document = copy.deepcopy(self.proposal)
                document['payload']['baseline'][field] = value
                self.rejected(c.validate, document, self.context)
        changed_context = copy.deepcopy(self.context)
        changed_context['baseline']['registrySHA256'] = 'd' * 64
        for item in changed_context['evidence']:
            item['baseline']['registrySHA256'] = 'd' * 64
        self.rejected(c.validate, self.proposal, changed_context)

    def test_checkpoint_mutation_cannot_retain_old_approval(self):
        approved = self.approved()
        context = copy.deepcopy(self.context)
        for v in (approved['payload']['baseline'], context['baseline']):
            v['registrySHA256'] = 'd' * 64
        for inventory in (approved['payload']['evidence'], context['evidence']):
            for item in inventory:
                item['baseline']['registrySHA256'] = 'd' * 64
        self.assertEqual(self.rejected(c.validate, approved, context, True), 'approvalDigestMismatch')

    def test_missing_required_roles_each_rejected(self):
        for role in c.ROLES:
            with self.subTest(role=role):
                payload = copy.deepcopy(self.payload)
                payload['evidence'] = [e for e in payload['evidence'] if e['role'] != role]
                self.rejected(c.prepare, payload, self.context)

    def test_duplicate_conflicting_and_identical_roles_rejected(self):
        for changed in (False, True):
            payload = copy.deepcopy(self.payload)
            duplicate = copy.deepcopy(payload['evidence'][0])
            if changed:
                duplicate['sha256'] = 'd' * 64
                duplicate['evidenceID'] = 'invented-different'
            payload['evidence'].append(duplicate)
            self.rejected(c.prepare, payload, self.context)

    def test_unknown_role_and_reused_evidence_id_rejected(self):
        payload = copy.deepcopy(self.payload)
        payload['evidence'][0]['role'] = 'inventedUnknownRole'
        self.rejected(c.prepare, payload, self.context)
        payload = copy.deepcopy(self.payload)
        payload['evidence'][0]['evidenceID'] = payload['evidence'][1]['evidenceID']
        self.rejected(c.prepare, payload, self.context)

    def test_wrong_evidence_scope_and_content_rejected(self):
        for group, field, replacement in (('source', 'profileVersion', 'invented-v2'), ('source', 'inputSHA256', 'd' * 64),
                                           ('source', 'key', 'invented-other'), ('source', 'resourceID', 'invented-other'),
                                           ('mapping', 'version', 'invented-v2'), ('baseline', 'registrySHA256', 'd' * 64)):
            payload = copy.deepcopy(self.payload)
            payload['evidence'][0][group][field] = replacement
            self.rejected(c.prepare, payload, self.context)
        for field in ('sha256', 'locator'):
            payload = copy.deepcopy(self.payload)
            payload['evidence'][0][field] = 'd' * 64
            self.rejected(c.prepare, payload, self.context)

    def test_optional_s9_review_reference_not_snapshot_acceptance(self):
        payload, context = fixtures()
        extra = dict(copy.deepcopy(payload['evidence'][0]), role='s9Review', evidenceID='invented-s9-review')
        payload['evidence'].append(extra)
        context['evidence'].append(copy.deepcopy(extra))
        proposal = c.prepare(payload, context)
        self.assertEqual(len(proposal['payload']['evidence']), 7)
        self.assertIn('immutableS9SnapshotAcceptance', proposal['payload']['unresolvedPrerequisites'])

    def test_unresolved_prerequisites_retained_not_satisfied(self):
        self.assertEqual(set(self.approved()['payload']['unresolvedPrerequisites']), c.PREREQUISITES)
        for item in c.PREREQUISITES:
            payload = copy.deepcopy(self.payload)
            payload['unresolvedPrerequisites'].remove(item)
            self.rejected(c.prepare, payload, self.context)
        payload = copy.deepcopy(self.payload)
        payload['unresolvedPrerequisites'][0] = dict(status='satisfied')
        self.rejected(c.prepare, payload, self.context)

    def test_no_trip_id_field_or_target_and_separate_mode(self):
        for mutation in ('tripID', 'existingTarget', 'existingMode'):
            payload = copy.deepcopy(self.payload)
            if mutation == 'tripID':
                payload['tripID'] = 'trp_0123456789abcdef'
            elif mutation == 'existingTarget':
                payload['conclusion']['existingCanonicalTripTarget'] = 'trp_0123456789abcdef'
            else:
                payload['mode'] = 'existingTarget'
            self.rejected(c.prepare, payload, self.context)
        self.assertNotIn(b'trp_', c.canonical(self.proposal))

    def test_structural_and_semantic_competitors_cannot_collapse(self):
        for field, replacement in (('acceptedCanonicalCompetitors', 'noneAnywhere'),
                                   ('priorCanonicalTripBinding', 'noneAnywhere'),
                                   ('externalSemanticCompetition', 'globallyDisproved'),
                                   ('semanticDistinctnessFromAllSourceRows', True),
                                   ('distinctNewRunRequested', 1)):
            payload = copy.deepcopy(self.payload)
            payload['conclusion'][field] = replacement
            self.rejected(c.prepare, payload, self.context)
        payload = copy.deepcopy(self.payload)
        payload['conclusion']['noCompetitors'] = True
        self.rejected(c.prepare, payload, self.context)
        payload = copy.deepcopy(self.payload)
        payload['baselineCapability'] = 'noTripAnywhere'
        self.rejected(c.prepare, payload, self.context)

    def test_affirmative_reasoning_required_with_source_basis(self):
        for reasoning in ('', '   '):
            payload = copy.deepcopy(self.payload)
            payload['conclusion']['affirmativeReasoning'] = reasoning
            self.rejected(c.prepare, payload, self.context)
        payload = copy.deepcopy(self.payload)
        payload['conclusion']['basisEvidenceIDs'] = ['invented-firstRealTripBaselineAudit', 'invented-stationCrosswalk']
        self.rejected(c.prepare, payload, self.context)

    def test_malformed_timestamp_and_owner_mismatch(self):
        for value in ('2026-02-30T00:00:00Z', '2026-10-08', '2026-10-08T00:00:60Z',
                      '2026-10-08T00:00:00+00:00', '2026-10-08T00:00:00.0Z'):
            self.rejected(c.approve, self.proposal, self.context, c.proposal_digest(self.proposal['payload']),
                          'invented-owner', value, c.CONFIRMATION)
        self.rejected(c.approve, self.proposal, self.context, c.proposal_digest(self.proposal['payload']),
                      'invented-other-owner', '2026-10-08T00:00:00Z', c.CONFIRMATION)
        wrong = copy.deepcopy(self.context)
        wrong['ownerAuthority'] = 'invented-other-owner'
        self.rejected(c.validate, self.approved(), wrong, True)

    def test_approval_digest_authority_timestamp_mutations_rejected(self):
        for field, replacement in (('proposalSHA256', 'd' * 64), ('approvedContentSHA256', 'd' * 64),
                                   ('authorityID', 'invented-other-owner'), ('approvedAt', '2026-10-08T12:35:00Z')):
            approved = self.approved()
            approved['approval'][field] = replacement
            self.rejected(c.validate, approved, self.context, True)

    def test_authoritative_payload_mutations_all_bound(self):
        for field, replacement in (('requestID', 'invented-changed'), ('affirmativeReasoning', 'Invented changed reasoning')):
            approved = self.approved()
            target = approved['payload']['conclusion'] if field == 'affirmativeReasoning' else approved['payload']
            target[field] = replacement
            self.assertEqual(self.rejected(c.validate, approved, self.context, True), 'approvalDigestMismatch')

    def test_unknown_json_fields_every_level_rejected(self):
        for path in ((), ('payload',), ('payload', 'source'), ('payload', 'baseline'),
                     ('payload', 'mapping'), ('payload', 'conclusion'), ('payload', 'evidence', 0), ('approval',)):
            document = self.approved()
            target = document
            for part in path:
                target = target[part]
            target['inventedUnknown'] = True
            self.rejected(c.validate, document, self.context, True)
        context = copy.deepcopy(self.context)
        context['inventedUnknown'] = True
        self.rejected(c.validate, self.proposal, context)

    def test_duplicate_json_keys_including_escaped_spelling(self):
        for raw in (b'{"key":1,"key":2}', b'{"key":1,"k\\u0065y":2}', b'{"nested":{"x":0,"x":0}}'):
            self.assertEqual(self.rejected(c.decode, raw), 'duplicateJSONKey')

    def test_invalid_unicode_numbers_depth_and_size(self):
        for raw in (b'\xff', b'{"key":"\\ud800"}', b'{"\\udfff":0}', b'{"x":NaN}',
                    b'{"x":1.5}', b'{"x":Infinity}', b'{"x":12345678901234567}', b'[' * 33 + b']' * 33,
                    b' ' * (c.MAX_BYTES + 1)):
            self.rejected(c.decode, raw)
        for value in (True, 1.0):
            document = copy.deepcopy(self.proposal)
            document['schemaVersion'] = value
            self.rejected(c.validate, document, self.context)

    def test_safe_summary_has_no_source_values_or_reasoning(self):
        summary = json.dumps(c.summary(self.approved()), ensure_ascii=False)
        for value in (self.payload['source']['key'], self.payload['requestID'], self.payload['ownerAuthority'],
                      self.payload['source']['sourceID'], self.payload['conclusion']['affirmativeReasoning']):
            self.assertNotIn(value, summary)


class PrivateIOAndCLITests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='invented-correspondence-')
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        self.root.chmod(0o700)
        self.payload, self.context = fixtures()
        self.draft = self.save('draft.json', self.payload)
        self.context_path = self.save('context.json', self.context)
        self.proposal = self.root / 'proposal.json'
        self.approved = self.root / 'approved.json'

    def save(self, name, value):
        path = self.root / name
        path.write_bytes(c.canonical(value))
        path.chmod(0o600)
        return path

    def cli(self, command, path=None, extra=(), success=True):
        result = subprocess.run([sys.executable, '-B', '-W', 'error', str(Path(c.__file__).resolve()), command,
                                 '--input', str(path or self.draft), '--context', str(self.context_path), *extra],
                                capture_output=True, text=True)
        self.assertEqual(result.returncode, 0 if success else 1, result.stderr)
        self.assertNotIn(self.payload['source']['key'], result.stdout + result.stderr)
        self.assertNotIn(str(self.root), result.stdout + result.stderr)
        self.assertNotIn('Traceback', result.stderr)
        return result

    def prepare_cli(self):
        return self.cli('prepare', extra=('--output', str(self.proposal)))

    def test_actual_cli_prepare_inspect_approve_verify(self):
        before = self.draft.read_bytes(), self.context_path.read_bytes()
        result = self.prepare_cli()
        self.assertEqual(json.loads(result.stdout)['status'], 'unapprovedProposal')
        self.assertIsNone(c.read_private(str(self.proposal))['approval'])
        self.assertEqual(stat.S_IMODE(self.proposal.stat().st_mode), 0o600)
        result = self.cli('inspect', self.proposal)
        digest = json.loads(result.stdout)['proposalSHA256']
        self.cli('verify', self.proposal, success=False)
        self.cli('approve', self.proposal, ('--output', str(self.approved), '--proposal-sha256', digest,
                 '--authority', 'invented-owner', '--approved-at', '2026-10-08T12:34:56Z', '--approve-distinct-new-run'))
        self.assertEqual(stat.S_IMODE(self.approved.stat().st_mode), 0o600)
        result = self.cli('verify', self.approved)
        self.assertEqual(json.loads(result.stdout), dict(status='approvedRepresentationValid', evidenceAuthenticated=False,
                                                       registrationAuthorized=False, s9Accepted=False))
        self.assertEqual(before, (self.draft.read_bytes(), self.context_path.read_bytes()))
        self.assertEqual({p.name for p in self.root.iterdir()}, {'draft.json', 'context.json', 'proposal.json', 'approved.json'})

    def test_approve_cli_requires_deliberate_flag_and_exact_digest(self):
        self.prepare_cli()
        extra = ('--output', str(self.approved), '--proposal-sha256', 'd' * 64,
                 '--authority', 'invented-owner', '--approved-at', '2026-10-08T12:34:56Z')
        self.cli('approve', self.proposal, extra, success=False)
        self.cli('approve', self.proposal, (*extra, '--approve-distinct-new-run'), success=False)
        self.assertFalse(self.approved.exists())

    def test_approval_flag_abbreviation_rejected(self):
        self.prepare_cli()
        value = c.read_private(str(self.proposal))
        extra = ('--output', str(self.approved), '--proposal-sha256', c.proposal_digest(value['payload']),
                 '--authority', 'invented-owner', '--approved-at', '2026-10-08T12:34:56Z', '--approve-distinct')
        self.cli('approve', self.proposal, extra, success=False)
        self.assertFalse(self.approved.exists())

    def test_cli_argument_and_validation_errors_redacted(self):
        self.cli('inspect', extra=('--unknown', self.payload['source']['key']), success=False)
        payload = copy.deepcopy(self.payload)
        payload['conclusion']['existingCanonicalTripTarget'] = self.payload['source']['key']
        self.save('draft.json', payload)
        result = self.cli('prepare', extra=('--output', str(self.proposal)), success=False)
        self.assertEqual(result.stderr.strip(), 'invalidCorrespondenceAssertion')
        self.assertFalse(self.proposal.exists())

    def test_symlink_input_output_and_ancestor_rejected(self):
        link = self.root / 'link.json'
        link.symlink_to(self.draft)
        self.cli('inspect', link, success=False)
        self.cli('prepare', extra=('--output', str(link)), success=False)
        child = self.root / 'child'
        child.mkdir(mode=0o700)
        target = child / 'draft.json'
        target.write_bytes(self.draft.read_bytes()); target.chmod(0o600)
        directory_link = self.root / 'directory-link'
        directory_link.symlink_to(child, target_is_directory=True)
        self.cli('prepare', directory_link / 'draft.json', ('--output', str(self.proposal)), success=False)
        self.cli('prepare', extra=('--output', str(directory_link / 'output.json')), success=False)
        self.assertFalse((child / 'output.json').exists())

    def test_unsafe_file_and_parent_permissions_rejected(self):
        for mode in (0o644, 0o400, 0o660, 0o1600):
            self.draft.chmod(mode)
            self.cli('prepare', extra=('--output', str(self.proposal)), success=False)
        self.draft.chmod(0o600)
        self.root.chmod(0o755)
        self.cli('prepare', extra=('--output', str(self.proposal)), success=False)
        self.root.chmod(0o700)

    def test_hardlink_fifo_and_wrong_owner_rejected(self):
        link = self.root / 'hardlink.json'
        os.link(self.draft, link)
        self.cli('prepare', extra=('--output', str(self.proposal)), success=False)
        link.unlink()
        fifo = self.root / 'fifo'
        os.mkfifo(fifo, mode=0o600)
        self.cli('inspect', fifo, success=False)
        with mock.patch.object(c.os, 'geteuid', return_value=os.geteuid() + 1):
            with self.assertRaises(c.RequestError):
                c.read_private(str(self.draft))

    def test_relative_dot_escape_repository_paths_rejected(self):
        for path in ('relative.json', str(self.root) + '/./draft.json', str(self.root) + '/../draft.json',
                     str(self.root) + '//draft.json', c.REPOSITORY + '/invented.json',
                     str(self.root) + '/.git/draft.json', str(self.root) + '/bad\x00.json'):
            with self.subTest(path=repr(path)), self.assertRaises(c.RequestError):
                c.read_private(path)
        self.cli('prepare', extra=('--output', c.REPOSITORY + '/invented.json'), success=False)

    def test_repository_ancestry_inode_rejects_lexical_alias(self):
        # Simulate a casing/volume alias missing the lexical path comparison.
        with mock.patch.object(c, 'REPOSITORY', str(self.root)), mock.patch.object(c.os.path, 'commonpath', return_value='/'):
            with self.assertRaises(c.RequestError) as caught:
                c.read_private(str(self.draft))
            self.assertEqual(str(caught.exception), 'repositoryPathForbidden')
            with self.assertRaises(c.RequestError):
                c.write_private(str(self.proposal), self.payload)

    def test_size_bound_and_bounded_read(self):
        self.draft.write_bytes(b'x' * (c.MAX_BYTES + 1))
        self.cli('prepare', extra=('--output', str(self.proposal)), success=False)
        self.assertFalse(self.proposal.exists())
        with self.assertRaises(c.RequestError):
            c.write_private(str(self.proposal), {'invented': 'x' * c.MAX_BYTES})

    def test_atomic_no_clobber_and_cleanup_on_write_failure(self):
        original = self.draft.read_bytes()
        with self.assertRaises(c.RequestError):
            c.write_private(str(self.draft), {'invented': 'replacement'})
        self.assertEqual(self.draft.read_bytes(), original)
        for operation in ('write', 'link', 'fsync'):
            with self.subTest(operation=operation), mock.patch.object(c.os, operation, side_effect=OSError('invented private error')):
                with self.assertRaises(c.RequestError):
                    c.write_private(str(self.proposal), self.payload)
            self.assertFalse(self.proposal.exists())
            self.assertFalse(any(p.name.startswith('.correspondence-') for p in self.root.iterdir()))

    def test_destination_race_preserves_existing_file(self):
        original_link = os.link
        def race(src, dst, **kwargs):
            self.proposal.write_bytes(b'invented-racing-file')
            self.proposal.chmod(0o600)
            return original_link(src, dst, **kwargs)
        with mock.patch.object(c.os, 'link', side_effect=race), self.assertRaises(c.RequestError):
            c.write_private(str(self.proposal), self.payload)
        self.assertEqual(self.proposal.read_bytes(), b'invented-racing-file')
        self.assertFalse(any(p.name.startswith('.correspondence-') for p in self.root.iterdir()))

    def test_parent_rename_detected_without_path_escape(self):
        child = self.root / 'private'
        child.mkdir(mode=0o700)
        target = child / 'draft.json'
        target.write_bytes(self.draft.read_bytes()); target.chmod(0o600)
        moved = self.root / 'moved'
        original_read = os.read
        first = True
        def race(fd, count):
            nonlocal first
            result = original_read(fd, count)
            if first:
                first = False
                child.rename(moved)
                child.mkdir(mode=0o700)
            return result
        with mock.patch.object(c.os, 'read', side_effect=race), self.assertRaises(c.RequestError):
            c.read_private(str(target))

    def test_input_mutation_detected(self):
        original_read = os.read
        changed = False
        def race(fd, count):
            nonlocal changed
            result = original_read(fd, count)
            if not changed:
                changed = True
                with self.draft.open('ab') as output:
                    output.write(b' ')
            return result
        with mock.patch.object(c.os, 'read', side_effect=race), self.assertRaises(c.RequestError):
            c.read_private(str(self.draft))

    def test_fixed_output_mode_even_under_restrictive_umask(self):
        previous = os.umask(0o777)
        try:
            c.write_private(str(self.proposal), self.payload)
        finally:
            os.umask(previous)
        self.assertEqual(stat.S_IMODE(self.proposal.stat().st_mode), 0o600)
        self.assertEqual(c.read_private(str(self.proposal)), self.payload)


if __name__ == '__main__':
    unittest.main()
