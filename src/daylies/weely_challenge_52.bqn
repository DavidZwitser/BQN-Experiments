chars ← ('a'⊸+∾'A'⊸+)↕26
lines ← •file.Lines "unigram_freq.csv"
Lower ← +⟜(32×1="A["⊸⍋)
lines_spilt ← {1⊸↓⌾(1⊸⊑)(+`=⟜',')⊸⊔}¨ lines

text ← "hello Beatifull cat"
•SHow words ≍ ⊑¨ {/ 𝕩⊸≡¨ ⊑¨lines}¨ words ← Lower¨ {{∨´ 𝕩⊸=¨ chars}¨𝕩}⊸/¨ (+` =⟜' ')⊸⊔ text
