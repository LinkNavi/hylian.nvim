; ── Hylian indentation for nvim-treesitter ───────────────────────────────────

; Any { … } block increases indent
[
  (block)
  (class_body)
  (switch_stmt)
  (unsafe_block)
] @indent.type

; Opening braces indent
"{" @indent.begin

; Closing braces de-indent
"}" @indent.end

; else keeps the same indent level as the previous closing brace
(if_stmt
  "else" @indent.branch)
