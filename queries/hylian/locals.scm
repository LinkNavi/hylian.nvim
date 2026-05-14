; ── Hylian locals for nvim-treesitter ────────────────────────────────────────
; Used for scope-aware features: rename, references, select, etc.

; ── Scopes ────────────────────────────────────────────────────────────────────

(source_file) @local.scope
(func_decl)   @local.scope
(method_decl) @local.scope
(ctor_decl)   @local.scope
(block)       @local.scope

; ── Definitions ───────────────────────────────────────────────────────────────

(func_decl
  name: (identifier) @local.definition)

(method_decl
  name: (identifier) @local.definition)

(ctor_decl
  name: (identifier) @local.definition)

(class_decl
  name: (identifier) @local.definition)

(enum_decl
  name: (identifier) @local.definition)

(enum_variant
  name: (identifier) @local.definition)

(var_decl_stmt
  name: (identifier) @local.definition)

(static_var_stmt
  name: (identifier) @local.definition)

(const_var_stmt
  name: (identifier) @local.definition)

(static_array_stmt
  name: (identifier) @local.definition)

(declare_assign_stmt
  name: (identifier) @local.definition)

(param
  name: (identifier) @local.definition)

(for_in_stmt
  variable: (identifier) @local.definition)

(field_decl
  name: (identifier) @local.definition)

; ── References ────────────────────────────────────────────────────────────────

(identifier) @local.reference
