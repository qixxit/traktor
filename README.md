# Traktor

  `Traktor` is a library to execute actions in a traceable manner by applying a two-phase-commit pattern.

  It is mainly defined by two behaviours:
  - `Traktor.Action` for the business logic;
  - `Traktor.Store` for the persistance layer.

  More details in the blog post: https://medium.com/qixxit-development/expecting-the-unexpected-37ee97e7f6a2  

  Example application: https://github.com/qixxit/two_phase_commit_example
