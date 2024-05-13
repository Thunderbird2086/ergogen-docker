#!/usr/bin/env bash

finish_abnormal() {
  :
}

finish_normal() {
  :
}

trap finish_abnormal INT TERM
trap finish_normal EXIT

usage="

$(basename "$0") -h

$(basename "$0") -i DIR

$(basename "$0") -o OUTOUT [--skip-vanilla] [--dont-clear] [SOURCE .. ]


  Description here

  -h              - Help

  -i DIR          - Only update index.js inside DIR.
                    No footprints will be downloaded.
                    Existing footprints inside DIR (non-recursive) will be used.
                    Resulting index.js will be created inside DIR.
                    Existing index.js will be overriden.

  -o OUTPUT       - Where to place all downloaded footprints and resulting index.js.
                    index.js will be created afresh from all .js files in OUTPUT.
                    Existing index.js will be overriden.
                    If directory does not exists it will be created.

  --dont-clear    - Do not clear OUTPUT dir before downloading footprints.
                    By default we delete eve

  --skip-vanilla  - Do NOT download vanila footprints from ergogen repo.
                    By default vanilla footprints from ergogen repo will be downloaded without explicit request.

  SOURCE            List of sources where to acquire footprints.
                    If no SOURCE are specified only vanilla ergogen footprints will be downloaded.
                    If no SOURCE are specified and --skip-vanilla is set nothing will be downloaded and --dont-clear will be ignored.
                    If no SOURCE are specified index.js will not be updated because vanilla footprints folder already contains valid one.

  When multiple SOURCEs are specified they will be merged into single OUTPUT directory.
  In case of collision (two or more footprint files with same name) only one of them will be left in OUTPUT directory.
  No guarantees are given on order of downloading SOURCES and hence order of overriding files during collision.

  This tools is trying to be intelligent in interpretation of what SOURCE can possibly be.
  You can speficy following things as SOURCE:

  local directory
  - all .js files in root of directory will be used (non-recursive)

  git repo
  - Footprints from any git repo can be downloaded.
    In this case SOURCE is expected to use syntax that is suitable to feed directly into 'git' command.
    Additionally tool supports syntax to specify exact directory in repo where to look for footprints.
    To specify directory add # and folder path relative to root of repo (for example '#src/footprints' for vanilla ergogen repo).
    See EXAMPLES below.

  ergogen git repo
  - By default tool will download vanilla footprints from default branch of official ergogen repo (unless --skip-vanila is set).
    In case you need footprints from specific branch, tag or commit it is possible to override default behaviour.
    If SOURCE points to official ergogen repo (read contains 'github.com/ergogen/ergogen') vanilla footprint will be download
    from SOURCE instead of implicitly downloading it from default branch.
    If directory specified with # syntax it will be used instead of default (which is 'src/footprints')
    If specified --skip-vanilla will be ignored.
    See EXAMPLES below.



  EXAMPLES:

  Update index.js:

  $(basename "$0") -i ./footprints


  Download vanilla footprints (index.js will be downloaded from ergogen repo and will not be generated):

  $(basename "$0") -o ./footprints
  

  Use only locally stored footprints:

  $(basename "$0") -o ./footprints --skip-vanilla SOME_DIR_WITH_FOOTPRINTS/


  Download external footprints from github (extra footprints will be downloaded alongside with vanilla footprints):

  $(basename "$0") -o ./footprints "https://github.com/ceoloide/ergogen-footprints.git"


  TODO: dowload from specific branch and with custom path

  $(basename "$0") -o ./footprints "https://github.com/ceoloide/ergogen-footprints.git"

"

# [ $# -eq 1  ] || { printf "$usage"; exit 2; }

m() {
  ## Usage# m "$MESSAGE"
  printf "[- INFO --- ] $1\n"
}

err() {
  ## Usage (w exit)  # mkdir "$DIR" || err 'cannot create dir' 1
  ## Usage (wo exit) # mkdir "$DIR" || err 'cannot create dir'
  local message="$1"; shift
  local exit_code="$1"; shift

  [ -n "$message" ] && printf "[- ERR ---- ] $message\n" >&2
  [ -n "$exit_code" ] && exit "$exit_code"
}

do_help() {
  echo "$usage"
  exit 0
}

do_error() {
  local text="$1"; shift
  local code="$1"; shift

  echo "$text"
  # echo "$usage";

  exit code
}




main() {
  local output
  local skip_vanilla=0
  local dont_clear=0
  local sources=()

  while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h) echo help;;
        -o) output="$2"; shift ;;
        --skip-vanilla) skip_vanilla=1 ;;
        --dont-clear) dont_clear=1 ;;
        # *) do_error "Unknown parameter passed: $1" 127 ;;
        *) {
            # [[ "$1" == *"github.com/ergogen/ergogen"* ]] && skip_vanilla=1 ;;
            [[ "$1" == *"github.com/ergogen/ergogen"* ]] && skip_vanilla=1;
            sources+=( "$1" ); 
           } ;;
    esac
    shift
  done

  [ skip_vanilla ] || sources+=( "https://github.com/ergogen/ergogen.git#src/footprints" )

  m ""
  m "Output dir: $output"
  m ""
  local t=$([ $skip_vanilla ] && echo "True" || echo "False")
  m "Skipping vanilla: $t"
  local t=$([ $dont_clear ] && echo "True" || echo "False")
  m "Don't clear output dir: $t"

  # todo: 
  # validate sources
  # remove invalid
  # print invalid list

  m ""
  m "Using these sources:"
  for s in ${sources[@]}; do
    m "$s"
  done
}

main "$@"