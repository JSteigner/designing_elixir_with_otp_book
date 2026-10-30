# Used by "mix format"

[
  inputs: [
    "{mix,.formatter}.exs",
    "{config,lib,test}/**/*.{ex,exs}",
    "/mastery_persistence/{config,lib,test}/**/*.{ex,exs}"
  ],
  locals_without_parens: [
    # Add the specific macros you want to keep paren-less:
    field: 2,
    field: 3,
    belongs_to: 2,
    belongs_to: 3,
    has_many: 2,
    has_three: 3,
    timestamps: 0,
    timestamps: 1,
    assert: 1,
    assert: 2,
    refute: 1,
    refute: 2
  ],
  # Export them so other applications importing your project honor this style
  export: [
    locals_without_parens: [
      field: 2,
      field: 3,
      belongs_to: 2,
      belongs_to: 3,
      has_many: 2,
      has_three: 3,
      timestamps: 0,
      timestamps: 1,
      assert: 1
    ]
  ]
]
