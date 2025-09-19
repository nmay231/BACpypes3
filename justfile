set unstable

[script, unix]
bdist:
    # remove everything in the current dist/ directory
    [ -d dist ] && rm -Rfv dist

    # start with a clean build directory
    [ -d build ] && rm -Rfv build

    # use the build package
    python3 -m build --no-isolation

    echo
    echo	This is what was built...
    echo
    ls -1 dist/
    echo

    # copy the wheel into the docker samples
    cp -v dist/*.whl samples/docker/

    echo

[script, unix]
check_install:
    for version in 3.7 3.8 3.9 3.10;
    do
    if [ -a "`which python$version`" ]; then
        echo "===== $version ====="
        python$version check-install.py
        echo
    fi
    done

[script, unix]
release_to_pypi:
    # build a distribution
    . bdist.sh

    read -p "Upload to PyPI? [y/n/x] " yesno || exit 1

    if [ "$yesno" = "y" ] ;
    then
        python3 -m twine upload dist/*
    elif [ "$yesno" = "n" ] ;
    then
        echo "Skipped..."
    else
        echo "exit..."
        exit 1
    fi

[script, unix]
release_to_testpypi:
    # build a distribution
    . build_dist.sh

    read -p "Upload to Test PyPI? [y/n/x] " yesno || exit 1

    if [ "$yesno" = "y" ] ;
    then
        twine upload -r testpypi --config-file .pypirc dist/*
    elif [ "$yesno" = "n" ] ;
    then
        echo "Skipped..."
    else
        echo "exit..."
        exit 1
    fi


[script, unix]
testpypi_install_bacpypes3:
    python3 -m pip install --upgrade \
        --index-url https://test.pypi.org/simple/ \
        --extra-index-url https://pypi.org/simple/ \
        bacpypes3
    python3 -c 'import bacpypes3; print("bacpypes3:", bacpypes3.__version__, bacpypes3.__file__)'
