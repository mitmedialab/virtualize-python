#!/bin/bash

if [[ "${BASH_SOURCE-}" != "$0" ]]; then
    echo "You cannot source this script. Run it as ./$0" >&2
    exit 33
fi

INSTALL_VERSION="3"
if [[ $1 ]]; then
    INSTALL_VERSION="$1"
fi

VIRTUALIZE_PYTHON_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE}" )" &> /dev/null && pwd )

PYTHON_CMD_LIST=( python python2 python3 )
PYTHON_VERS=()
PYTHON_EXES=()
FOUND_A_PYTHON=""

for p in ${PYTHON_CMD_LIST[@]}; do
    #echo "checking for $p"
    if $( which $p 2>&1 > /dev/null ); then
	PYTHON_EXES+=( $( which $p ) )
	PYTHON_VERS+=( $( $p --version 2>&1 | cut -d " " -f2 ) )
	FOUND_A_PYTHON="true"
    else
	PYTHON_EXES+=( "" )
	PYTHON_VERS+=( "" )
    fi
done

if [[ ! $FOUND_A_PYTHON ]]; then
    echo "error: could not find any installed pythons in your \$PATH"
    echo "a python install is required to use virtualize-python"
    echo "looked for: ${PYTHON_CMD_LIST[@]}"
    exit 33
fi

SELECTED_EXE=""
SELECTED_VER=""
for i in ${!PYTHON_CMD_LIST[@]}; do
    cmd=${PYTHON_CMD_LIST[$i]}
    exe=${PYTHON_EXES[$i]}
    ver=${PYTHON_VERS[$i]}
    if [[ "${ver}." == ${INSTALL_VERSION}.* ]]; then
	SELECTED_EXE="$exe"
	SELECTED_VER="$ver"
	echo "found a match for the requested version! $SELECTED_VER $SELECTED_EXE"
	break
    fi
done

if [[ ! $SELECTED_EXE ]]; then
    echo "error: could not find desired python version $INSTALL_VERSION"
    echo "here are the found versions:"
    for i in ${!PYTHON_CMD_LIST[@]}; do
	cmd=${PYTHON_CMD_LIST[$i]}
	exe=${PYTHON_EXES[$i]}
	ver=${PYTHON_VERS[$i]}
	if [[ ! $ver ]]; then
	    continue
	fi
	echo "$cmd	$ver	$exe"
    done
    exit 33
fi

# if [[ "${SELECTED_VER}." == 2.* || "${SELECTED_VER}." == 3.* ]]; then
#     # note: using virtualenv for both 2 and 3 for now, venv section below is not actually used
if [[ "${SELECTED_VER}." == 2.* ]]; then
    # well, i'd *like* to use virtualenv for both but it's erroring out on python 3
    echo "using virtualenv"
    cd $VIRTUALIZE_PYTHON_DIR
    # FIXME should probably support both curl and wget someday, look at how 'n' does it
    curl -O https://bootstrap.pypa.io/virtualenv.pyz
    $SELECTED_EXE virtualenv.pyz --python $SELECTED_EXE $VIRTUALIZE_PYTHON_DIR/python
    #rm virtualenv.pyz  # FIXME uncomment when finished debugging
elif [[ "${SELECTED_VER}." == 3.* ]]; then
    echo "using venv"
    $SELECTED_EXE -m venv $VIRTUALIZE_PYTHON_DIR/python
    echo "python installed"
else
    echo "error: sorry, virtualize-python only support python 2 and python 3 currently"
    exit 33
fi

    


## Notes:
## we might be able to just do normal install and use the `brew config --prefix` command
## instead of cloning and building from the repo
## rename homebrew install dir to just brew (to match the repo name)?
## don't forget the .gitignore dir if ^^^
## are man pages a thing?
## if we do keep installing by cloning the repo, colne the repo into one dir,
## then install into another dir and removing the cloned repo dir?
## maybe we should have a list of brew packages that need to be installed for a given project?
