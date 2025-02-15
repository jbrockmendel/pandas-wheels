# Define custom utilities
# Test for OSX with [ -n "$IS_OSX" ]

function pre_build {
    # Any stuff that you need to do before you start building the wheels
    # Runs in the root directory of this repository.
    if [ -n "$IS_OSX" ]; then
        # Override pandas' default minimum MACOSX_DEPLOYEMENT_TARGET=10.9,
        # so we can build for older Pythons if we really want to.
        # See https://github.com/pandas-dev/pandas/pull/24274
        local _plat=$(get_distutils_platform)
        if [[ -z $MACOSX_DEPLOYMENT_TARGET && "$_plat" =~ macosx-(10\.[0-9]+)-.* ]]; then
            export MACOSX_DEPLOYMENT_TARGET=${BASH_REMATCH[1]}
        fi
    fi
}

function build_wheel {
    # Override common_utils build_wheel function to fix version error
    # Version error due to versioneer inside submodule
    build_bdist_wheel $@
}


function pip_opts {
    # Add pre-release index until official NumPy release with 3.8
    if [ -n "$MANYLINUX_URL" ]; then
        echo "--find-links $MANYLINUX_URL --find-links=https://7933911d6844c6c53a7d-47bd50c35cd79bd838daf386af554a83.ssl.cf2.rackcdn.com"
    else
        echo "--find-links=https://7933911d6844c6c53a7d-47bd50c35cd79bd838daf386af554a83.ssl.cf2.rackcdn.com"
    fi
}

function run_tests {
    # Runs tests on installed distribution from an empty directory
    export PYTHONHASHSEED=$(python -c 'import random; print(random.randint(1, 4294967295))')
    python -c 'import pandas; pandas.show_versions()'
    python -c 'import pandas; pandas.test(extra_args=["--skip-slow", "--skip-network", "--skip-db", "-n=2", "-k -test_groupby_empty"])'
}
