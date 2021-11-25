use str

use github.com/zzamboni/elvish-completions/comp

fn -once-fn [func]{
  cached-value = $nil
  put {
    if (not $cached-value) {
      cached-value = [($func)]
    }
    all $cached-value
  }
}

# Provides completions for a comma-separated list of a limited set of values.
# For example, if the values are "foo", "bar", and "baz", the completions for
# "b" will be "bar" and "baz", while completions for "foo,b" will be "foo,bar"
# and "foo,baz". Also offers an "all" value which cannot be specified with any
# other values.
fn -comma-sep-list [options arg]{
  prefix = $arg[..(+ 1 (str:last-index $arg ','))]
  for option $options {
    put $prefix$option
  }
  put all
}

-scm-names = [ git cipd ]

-opt-completers = [
  &CONFIG_FILENAME=$comp:files~
  &DEPS_FILE=$comp:files~
  &IGNORE_DEP_TYPE=$-scm-names
  &OS_LIST=[arg]{
    # The list of possible values comes from the values (not keys) of
    # DEPS_OS_CHOICES in gclient.py.
    -comma-sep-list [ unix win mac unix android ios fuchsia chromeos ] $arg
  }
  &OUTPUT_JSON=$comp:files~
  &SCM=$-scm-names
  &SPEC=$comp:files~
]

fn -extract-opts [subcommand]{
  # The default regex for comp:extract-opts, with a non-capturing group added
  # for a required argument after the one-letter option.
  extract-regex = '^\s*(?:-(\w)(?:\s+\S+)?,?\s*)?(?:--?([\w-]+))?(?:\[=(\S+)\]|[ =](\S+))?\s*?\s\s(\w.*)$'
  -once-fn { gclient help $subcommand | comp:extract-opts &fold &regex=$extract-regex &opt-completers=$-opt-completers}
}

fn -opts-only [subcommand]{
  comp:sequence &opts=(-extract-opts $subcommand) []
}

-recurse-completer = [@cmd]{
  # gclient recurse takes a set of options followed by an external command. We
  # can use edit:complete-sudo to handle this, but first have to strip the opts
  # for gclient recurse...
  start-index = 1
  next-is-opt-arg = $false
  for arg [$@cmd][1..] {
    if $next-is-opt-arg {
      start-index = (+ $start-index 1)
      next-is-opt-arg = $false
    } elif (eq $arg '--') {
      start-index = (+ $start-index 1)
      break
    } elif (str:has-prefix $arg '-') {
      start-index = (+ $start-index 1)

      # If it's an opt that takes an argument, the next argument needs to be
      # stripped too.
      if (has-key [&-j &--jobs &--gclientfile &--spec &-s &--scm] $arg) {
        next-is-opt-arg = $true
      }
    } else {
      break
    }
  }
  # The first argument to complete-sudo doesn't seem to matter.
  edit:complete-sudo recurse (all [$@cmd][$start-index..])
}

-grep-completer = [@cmd]{
  # gclient grep passes all its arguments to git grep, so we can use the
  # completions from that command (provided by @zzamboni's completion scripts).
  $edit:completion:arg-completer[git] git grep $@cmd
}

-subcmds = [
  &config=(-opts-only config)
  &diff=(-opts-only diff)
  &fetch=(-opts-only fetch)
  &flatten=(-opts-only flatten)
  &getdep=(-opts-only getdep)
  &grep=$-grep-completer
  &help=[]
  &metrics=(-opts-only metrics)
  &pack=(-opts-only pack)
  &recurse=(comp:sequence &opts=(-extract-opts recurse) [$-recurse-completer ...])
  &revert=(-opts-only revert)
  &revinfo=(-opts-only revinfo)
  &root=(-opts-only root)
  &runhooks=(-opts-only runhooks)
  &setdep=(-opts-only setdep)
  &status=(-opts-only status)
  &sync=(-opts-only sync)
  &validate=(-opts-only validate)
  &verify=(-opts-only verify)
]

-subcmds[help] = (comp:sequence [[(keys $-subcmds)]])

edit:completion:arg-completer[gclient] = (comp:subcommands $-subcmds)
