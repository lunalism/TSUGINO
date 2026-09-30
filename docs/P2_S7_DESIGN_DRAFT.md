# P2-S7 — Dated Language Evidence Note

**Status: Non-normative evidence note, 2026-09-30; no authorization.**

The design draft has been consolidated into **DEC-071 (Accepted, design only)** in `DECISIONS.md`. That record is the sole authoritative contract; this note retains only the useful read-only inventory from the earlier draft. It does not define selection, revision, search, binding or licensing policy. No source artifacts were changed, and no translation was authored. P2-S7 remains unstarted.

## Verified input availability, not accepted canonical names

Read-only inspection used the accepted archives and final P2-S5 registry, with no acquisition or artifact modification. Translation coverage below was checked by exact `table_name`, `field_name`, `field_value`, and language lookup, with one nonblank translation for each covered row and zero conflicting translation keys. Counts are row coverage, not newly inferred identities.

| Identified input | Japanese | English | Korean |
|---|---|---|---|
| Toei GTFS | 149/149 stop rows (141 reviewed operator-level identities), 6/6 routes, 1/1 agency | same coverage | 0 stops, routes, or agency |
| Tokyo Metro GTFS | 185/185 stop rows (144 reviewed operator-level identities), 9/9 routes, 1/1 agency | same coverage | 0 stops, routes, or agency |
| Tokyo Metro Railway titles | 10/10 records | 10/10 records | 9/10 records; these already cover 9 distinct reviewed canonical line IDs; branch record lacks Korean |
| Tokyo Metro Railway station-order titles | 186/186 entries | 186/186 entries | 186/186 entries; 186 distinct provider station references, **not yet mapped to canonical stations** |

Provenance:

| Input | SHA-256 |
|---|---|
| Toei archive | `dd5757062317dcf18b8eeaf8bf83f6624ecd3c9fc4fe99918981e5ec2b42d8c4` |
| Toei `translations.txt` member | `a0d277d958182408cf31d3bae1912f31be2338f5214348611c1a0f367de8d61c` |
| Tokyo Metro archive | `76f046236893b136f0d84b2e2ce21db67375a90e63c9e594732e1bec48a277e1` |
| Tokyo Metro `translations.txt` member | `c9d8095fcb430cf890db680acbb253882c7c269bbe8993321bb9478d7d7c932b` |
| Tokyo Metro Railway snapshot | `90b16083b4acfd73d4ad4dc840f6702e57799279d05d1e6781961c8ab3b97f6c` |
| Final P2-S5 registry, revision 6 | `9fda4419d192739c147d2cee2290b07f547e76a99c71a949fc4fe0322be8364b` |

The registry already retains Japanese/English originals for all 334 GTFS stop references and 15 route references. Its Railway record references retain all supplied title languages, including the 9 Korean line-title inputs, with `odpt:railwayTitle` provenance. Both GTFS agency English translations are available in the retained archives but are **not yet carried in the agency references' original-name arrays**, which currently hold Japanese only. This is a bounded name-intake requirement, not absence of source English.

The 258 canonical station groups expose 256 single-valued and 2 multi-valued Japanese input-name sets, and 257 single-valued and 1 multi-valued English sets. These counts do not choose display names. The P2-S6 coordinate convention does not apply to names.

No Korean agency-name input was found in these identified sources. No Toei Korean station/line input exists in these GTFS inputs. Metro's Korean station-order titles are provider-supplied text, not generated translations, but their 186 references have no accepted station binding in the final registry (DEC-068 §D6). Their presence proves neither 144 canonical station coverage nor approved Korean display names. Reviewed source-to-station evidence is still needed, including overlaps and branch scope; names alone must not establish identity.
