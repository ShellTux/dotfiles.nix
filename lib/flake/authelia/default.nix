{ ... }:
let
  inherit (builtins)
    concatStringsSep
    isList
    length
    sort
    stringLength
    ;
in
rec {
  specificityScore =
    rule:
    let
      domainScore =
        if rule.domain == null then
          0
        else if isList rule.domain then
          length (concatStringsSep "" rule.domain)
        else
          stringLength rule.domain;

      resourcesScore = length rule.resources;
      methodsScore = length rule.methods;
      subjectScore = length rule.subject;
      networksScore = length rule.networks;
      queryScore = length rule.query;
    in
    domainScore
    + resourcesScore * 10
    + methodsScore * 10
    + subjectScore * 10
    + networksScore * 10
    + queryScore * 10;

  # Sort by domain, then specificity
  sortRules =
    rules:
    sort (
      a: b:
      let
        da =
          if a.domain == null then
            ""
          else if isList a.domain then
            concatStringsSep "," a.domain
          else
            a.domain;

        db =
          if b.domain == null then
            ""
          else if isList b.domain then
            concatStringsSep "," b.domain
          else
            b.domain;

        sa = specificityScore a;
        sb = specificityScore b;
      in
      if da == db then
        sa > sb # more specific first
      else
        da < db # alphabetical domain order
    ) rules;
}
