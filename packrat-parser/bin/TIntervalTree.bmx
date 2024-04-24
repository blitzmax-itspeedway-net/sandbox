'   NAME
'   (c) Copyright Si Dunford, MMM 2022, All Rights Reserved. 
'   VERSION: 1.0

'   CHANGES:
'   DD MMM YYYY  Initial Creation
'

SuperStrict


procedure Overlaps(𝑛, [𝑙, ℎ), 𝑟 )
2: If 𝑙 > 𝑛𝑚𝑎𝑥 Then
3: Return 𝑟
4: 𝑟 ← Overlaps(𝑛Left , [𝑙, ℎ), 𝑟 )
5: If HasOverlap([𝑙, ℎ), 𝑛interval ) Then
6: 𝑟 ← 𝑟 :: 𝑛interval
7: If ℎ < 𝑛𝑠𝑡𝑎𝑟𝑡 Then
8: Return 𝑟
9: 𝑟 ← Overlaps(𝑛Right , [𝑙, ℎ), 𝑟 )
10: Return 𝑟
11: procedure HasOverlap([𝑙1, ℎ1), [𝑙2, ℎ2))
12: Return 𝑙1 < ℎ2 ∧ ℎ1 > 𝑙2