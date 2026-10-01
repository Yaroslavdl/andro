# CP/AA dependency map

## Known evidence
- DUDU: working.
- Previous successful Lineage builds: image output, physical touch and resolution adaptation worked.

## Planes to map
| Plane | DUDU | Old Lineage | Target | Evidence |
| --- | --- | --- | --- | --- |
| projection/control transport | ? | working at feature level | ? | |
| video/image output | working | working | ? | |
| touch/input return | working | working | ? | |
| resolution adaptation | working | working | ? | |
| media audio | ? | worked in some builds | ? | |
| call audio interaction | ? | partial/broken via OEM BT | ? | |

## Dependency chain
To be populated from local evidence:
`phone -> transport/OEM service -> projection stack -> video/input/audio integration -> head unit`

## First local-analysis questions
1. Which OEM packages/processes appear in old successful CP/AA build scripts and logs?
2. Which corresponding processes run on DUDU?
3. Which vendor libraries, sockets, device nodes and properties do they use?
4. Which old patches were strictly resolution/touch adaptations versus required transport integration?
