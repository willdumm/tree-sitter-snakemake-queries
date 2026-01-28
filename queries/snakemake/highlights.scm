["," "." ":" ";" (ellipsis)] @punctuation.delimiter
["(" ")" "[" "]" "{" "}"] @punctuation.bracket
(interpolation
  "{" @punctuation.special
  "}" @punctuation.special) @embedded

[
  "-"
  "-="
  "!="
  "*"
  "**"
  "**="
  "*="
  "/"
  "//"
  "//="
  "/="
  "&"
  "&="
  "%"
  "%="
  "^"
  "^="
  "+"
  "->"
  "+="
  "<"
  "<<"
  "<<="
  "<="
  "<>"
  "="
  ":="
  "=="
  ">"
  ">="
  ">>"
  ">>="
  "|"
  "|="
  "~"
  "@="
] @operator

[
  "as"
  "assert"
  "await"
  "from"
  "pass"

  "with"
] @keyword.control

[
  "if"
  "elif"
  "else"
  "match"
  "case"
] @keyword.control.conditional

[
  "while"
  "for"
  "break"
  "continue"
] @keyword.control.repeat

[
  "return"
  "yield"
] @keyword.control.return
(yield "from" @keyword.control.return)

[
  "raise"
  "try"
  "except"
  "finally"
] @keyword.control.except
(raise_statement "from" @keyword.control.except)
"import" @keyword.control.import

(for_statement "in" @keyword.control)
(for_in_clause "in" @keyword.control)

[
  "async"
  "class"
  "exec"
  "global"
  "nonlocal"
  "print"
  "type"
] @keyword
[
  "and"
  "or"
  "not in"
  "in"
  "not"
  "del"
  "is not"
  "is"
] @keyword.operator

; Literals
(none) @constant.builtin
[
  (true)
  (false)
] @constant.builtin.boolean

(integer) @constant.numeric.integer
(float) @constant.numeric.float
(comment) @comment
(string) @string
(escape_sequence) @constant.character.escape

; Variables

(identifier) @variable

(attribute attribute: (identifier) @variable.other.member)

; Imports

(dotted_name
  (identifier)* @namespace)

(aliased_import
  alias: (identifier) @namespace)

; Function calls

[
  "def"
  "lambda"
] @keyword.function

(call
  function: (attribute attribute: (identifier) @function.method))

(call
  function: (identifier) @function)

(call
  function: (attribute attribute: (identifier) @constructor)
 (#match? @constructor "^[A-Z]"))
(call
  function: (identifier) @constructor
 (#match? @constructor "^[A-Z]"))

; Builtin functions

((call
  function: (identifier) @function.builtin)
 (#match?
   @function.builtin
   "^(abs|all|any|ascii|bin|bool|breakpoint|bytearray|bytes|callable|chr|classmethod|compile|complex|delattr|dict|dir|divmod|enumerate|eval|exec|filter|float|format|frozenset|getattr|globals|hasattr|hash|help|hex|id|input|int|isinstance|issubclass|iter|len|list|locals|map|max|memoryview|min|next|object|oct|open|ord|pow|print|property|range|repr|reversed|round|set|setattr|slice|sorted|staticmethod|str|sum|super|tuple|type|vars|zip|__import__)$"))

; Function definitions

(function_definition
  name: (identifier) @function)

(function_definition
  name: (identifier) @constructor
 (#match? @constructor "^(__new__|__init__)$"))

; Decorators

(decorator) @function
(decorator (identifier) @function)
(decorator (attribute attribute: (identifier) @function))
(decorator (call
  function: (attribute attribute: (identifier) @function)))

; Parameters

(parameters (identifier) @variable.parameter)
(parameters (typed_parameter (identifier) @variable.parameter))
(parameters (default_parameter name: (identifier) @variable.parameter))
(parameters (typed_default_parameter name: (identifier) @variable.parameter))

(parameters
  (list_splat_pattern ; *args
    (identifier) @variable.parameter))
(parameters
  (dictionary_splat_pattern ; **kwargs
    (identifier) @variable.parameter))

(lambda_parameters
  (identifier) @variable.parameter)

; Builtins, constants, etc.

((identifier) @variable.builtin
 (#match? @variable.builtin "^(self|cls)$"))

((identifier) @type.builtin
  (#match? @type.builtin
    "^(BaseException|Exception|ArithmeticError|BufferError|LookupError|AssertionError|AttributeError|EOFError|FloatingPointError|GeneratorExit|ImportError|ModuleNotFoundError|IndexError|KeyError|KeyboardInterrupt|MemoryError|NameError|NotImplementedError|OSError|OverflowError|RecursionError|ReferenceError|RuntimeError|StopIteration|StopAsyncIteration|SyntaxError|IndentationError|TabError|SystemError|SystemExit|TypeError|UnboundLocalError|UnicodeError|UnicodeEncodeError|UnicodeDecodeError|UnicodeTranslateError|ValueError|ZeroDivisionError|EnvironmentError|IOError|WindowsError|BlockingIOError|ChildProcessError|ConnectionError|BrokenPipeError|ConnectionAbortedError|ConnectionRefusedError|ConnectionResetError|FileExistsError|FileNotFoundError|InterruptedError|IsADirectoryError|NotADirectoryError|PermissionError|ProcessLookupError|TimeoutError|Warning|UserWarning|DeprecationWarning|PendingDeprecationWarning|SyntaxWarning|RuntimeWarning|FutureWarning|ImportWarning|UnicodeWarning|BytesWarning|ResourceWarning)$"))

((identifier) @type
 (#match? @type "^[A-Z]"))

((identifier) @constant
 (#match? @constant "^_*[A-Z][A-Z\\d_]*$"))

; Types

((identifier) @type.builtin
 (#match?
   @type.builtin
   "^(bool|bytes|dict|float|frozenset|int|list|set|str|tuple)$"))

; In type hints make everything types to catch non-conforming identifiers
; (e.g., datetime.datetime) and None
(type [(identifier) (none)] @type)
; Handle [] . and | nesting 4 levels deep
(type
  (_ [(identifier) (none)]? @type
    (_ [(identifier) (none)]? @type
      (_ [(identifier) (none)]? @type
        (_ [(identifier) (none)]? @type)))))

(class_definition name: (identifier) @type)
(class_definition superclasses: (argument_list (identifier) @type))

; Snakemake-specific highlights
; Compound directives
[
  "rule"
  "checkpoint"
  "module"
] @keyword

; Top level directives (eg. configfile, include)
(module
  (directive
    name: _ @keyword))

; Subordinate directives (eg. input, output)
body: (_
  (directive
    name: _ @label))

; rule/module/checkpoint names
(rule_definition
  name: (identifier) @type)

(module_definition
  name: (identifier) @type)

(checkpoint_definition
  name: (identifier) @type)

; Rule imports
(rule_import
  [
    "use"
    "rule"
    "from"
    "exclude"
    "as"
    "with"
  ] @keyword.import)

; Rule inheritance
(rule_inheritance
  "use" @keyword
  "rule" @keyword
  "with" @keyword)

; Wildcard names
(wildcard
  (identifier) @variable)

(wildcard
  (flag) @variable.parameter.builtin)

; builtin variables
((identifier) @variable.builtin
  (#any-of? @variable.builtin "checkpoints" "config" "gather" "rules" "scatter" "workflow"))

; References to directive labels in wildcard interpolations
; the #any-of? queries are moved above the #has-ancestor? queries to
; short-circuit the potentially expensive tree traversal, if possible
; see:
; https://github.com/nvim-treesitter/nvim-treesitter/pull/4302#issuecomment-1685789790
; directive labels in wildcard context
((wildcard
  (identifier) @label)
  (#any-of? @label "input" "jobid" "log" "output" "params" "resources" "rule" "threads" "wildcards"))

((wildcard
  (attribute
    object: (identifier) @label))
  (#any-of? @label "input" "jobid" "log" "output" "params" "resources" "rule" "threads" "wildcards"))

((wildcard
  (subscript
    value: (identifier) @label))
  (#any-of? @label "input" "jobid" "log" "output" "params" "resources" "rule" "threads" "wildcards"))

; directive labels in block context (eg. within 'run:')
; NOTE: #has-ancestor? is not supported by kak-tree-sitter, so this query is disabled
; ((identifier) @label
;   (#any-of? @label "input" "jobid" "log" "output" "params" "resources" "rule" "threads" "wildcards")
;   (#has-ancestor? @label "directive")
;   (#has-ancestor? @label "block"))
