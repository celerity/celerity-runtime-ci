#!/bin/bash

set -eu

export DEBIAN_FRONTEND=noninteractive
apt-get -q update
apt-get -q full-upgrade -y

PACKAGES=( "$@" )

source /etc/lsb-release

# Some package names depend on the LLVM version (=> Ubuntu version)
case "$DISTRIB_RELEASE" in
    20.04) LLVM=10 GCC=9;;
    22.04) LLVM=14 GCC=12;;
    23.04) LLVM=16 GCC=12;;
    *) echo "Unsupported Ubuntu version $DISTRIB_RELEASE">&2; exit 1;;
esac

# Substitute our made-up package names with Ubuntu versioned names
for i in "${!PACKAGES[@]}"; do
    case "${PACKAGES[i]}" in
        clang) PACKAGES[i]="clang-$LLVM";;
        libclang-dev) PACKAGES[i]="libclang-$LLVM-dev";;
        clang-tidy) PACKAGES[i]="clang-tidy-$LLVM";;
        clang-format) PACKAGES[i]="clang-format-$LLVM";;
        llvm-dev) PACKAGES[i]="llvm-$LLVM-dev";;
        lld) PACKAGES[i]="lld-$LLVM";;
        libomp-dev) PACKAGES[i]="libomp-$LLVM-dev";;
        libstdc++-dev) PACKAGES[i]="libstdc++-$GCC-dev";;
        libgcc-dev) PACKAGES[i]="libgcc-$GCC-dev";;
        libstdc++6-dbg) PACKAGES[i]="libstdc++6-$GCC-dbg";;
    esac
done

if [ $# -gt 0 ]; then
    apt-get -q install -y --no-install-recommends "${PACKAGES[@]}"
fi

# Don't keep around apt cache in docker image
apt-get -q clean
rm -rf /var/lib/apt/lists/*

if [ -d "/usr/lib/x86_64-linux-gnu/openmpi/include/openmpi" ]; then
    # HDF5 pkg-config exports an incorrect include path, which CMake chokes on
    ln -s /usr/lib/x86_64-linux-gnu/openmpi/include/openmpi /usr/include/openmpi
fi

if [[ -x "/usr/bin/llvm-config-$LLVM" && ( ! -f "/usr/bin/llvm-config" || $(update-alternatives --list llvm-config) ) ]]; then
    # From https://gist.github.com/hcoona/4e6d681c054e8aa2b877f7363ca5d220
    update-alternatives --quiet \
        --install /usr/bin/llvm-config llvm-config "/usr/bin/llvm-config-$LLVM" 10 \
        --slave /usr/bin/llvm-PerfectShuffle llvm-PerfectShuffle "/usr/bin/llvm-PerfectShuffle-$LLVM" \
        --slave /usr/bin/llvm-addr2line llvm-addr2line "/usr/bin/llvm-addr2line-$LLVM" \
        --slave /usr/bin/llvm-ar llvm-ar "/usr/bin/llvm-ar-$LLVM" \
        --slave /usr/bin/llvm-as llvm-as "/usr/bin/llvm-as-$LLVM" \
        --slave /usr/bin/llvm-bcanalyzer llvm-bcanalyzer "/usr/bin/llvm-bcanalyzer-$LLVM" \
        --slave /usr/bin/llvm-bitcode-strip llvm-bitcode-strip "/usr/bin/llvm-bitcode-strip-$LLVM" \
        --slave /usr/bin/llvm-c-test llvm-c-test "/usr/bin/llvm-c-test-$LLVM" \
        --slave /usr/bin/llvm-cat llvm-cat "/usr/bin/llvm-cat-$LLVM" \
        --slave /usr/bin/llvm-cfi-verify llvm-cfi-verify "/usr/bin/llvm-cfi-verify-$LLVM" \
        --slave /usr/bin/llvm-cov llvm-cov "/usr/bin/llvm-cov-$LLVM" \
        --slave /usr/bin/llvm-cvtres llvm-cvtres "/usr/bin/llvm-cvtres-$LLVM" \
        --slave /usr/bin/llvm-cxxdump llvm-cxxdump "/usr/bin/llvm-cxxdump-$LLVM" \
        --slave /usr/bin/llvm-cxxfilt llvm-cxxfilt "/usr/bin/llvm-cxxfilt-$LLVM" \
        --slave /usr/bin/llvm-cxxmap llvm-cxxmap "/usr/bin/llvm-cxxmap-$LLVM" \
        --slave /usr/bin/llvm-diff llvm-diff "/usr/bin/llvm-diff-$LLVM" \
        --slave /usr/bin/llvm-dis llvm-dis "/usr/bin/llvm-dis-$LLVM" \
        --slave /usr/bin/llvm-dlltool llvm-dlltool "/usr/bin/llvm-dlltool-$LLVM" \
        --slave /usr/bin/llvm-dwarfdump llvm-dwarfdump "/usr/bin/llvm-dwarfdump-$LLVM" \
        --slave /usr/bin/llvm-dwp llvm-dwp "/usr/bin/llvm-dwp-$LLVM" \
        --slave /usr/bin/llvm-elfabi llvm-elfabi "/usr/bin/llvm-elfabi-$LLVM" \
        --slave /usr/bin/llvm-exegesis llvm-exegesis "/usr/bin/llvm-exegesis-$LLVM" \
        --slave /usr/bin/llvm-extract llvm-extract "/usr/bin/llvm-extract-$LLVM" \
        --slave /usr/bin/llvm-gsymutil llvm-gsymutil "/usr/bin/llvm-gsymutil-$LLVM" \
        --slave /usr/bin/llvm-ifs llvm-ifs "/usr/bin/llvm-ifs-$LLVM" \
        --slave /usr/bin/llvm-install-name-tool llvm-install-name-tool "/usr/bin/llvm-install-name-tool-$LLVM" \
        --slave /usr/bin/llvm-jitlink llvm-jitlink "/usr/bin/llvm-jitlink-$LLVM" \
        --slave /usr/bin/llvm-jitlink-executor llvm-jitlink-executor "/usr/bin/llvm-jitlink-executor-$LLVM" \
        --slave /usr/bin/llvm-lib llvm-lib "/usr/bin/llvm-lib-$LLVM" \
        --slave /usr/bin/llvm-libtool-darwin llvm-libtool-darwin "/usr/bin/llvm-libtool-darwin-$LLVM" \
        --slave /usr/bin/llvm-link llvm-link "/usr/bin/llvm-link-$LLVM" \
        --slave /usr/bin/llvm-lipo llvm-lipo "/usr/bin/llvm-lipo-$LLVM" \
        --slave /usr/bin/llvm-lto llvm-lto "/usr/bin/llvm-lto-$LLVM" \
        --slave /usr/bin/llvm-lto2 llvm-lto2 "/usr/bin/llvm-lto2-$LLVM" \
        --slave /usr/bin/llvm-mc llvm-mc "/usr/bin/llvm-mc-$LLVM" \
        --slave /usr/bin/llvm-mca llvm-mca "/usr/bin/llvm-mca-$LLVM" \
        --slave /usr/bin/llvm-ml llvm-ml "/usr/bin/llvm-ml-$LLVM" \
        --slave /usr/bin/llvm-modextract llvm-modextract "/usr/bin/llvm-modextract-$LLVM" \
        --slave /usr/bin/llvm-mt llvm-mt "/usr/bin/llvm-mt-$LLVM" \
        --slave /usr/bin/llvm-nm llvm-nm "/usr/bin/llvm-nm-$LLVM" \
        --slave /usr/bin/llvm-objcopy llvm-objcopy "/usr/bin/llvm-objcopy-$LLVM" \
        --slave /usr/bin/llvm-objdump llvm-objdump "/usr/bin/llvm-objdump-$LLVM" \
        --slave /usr/bin/llvm-opt-report llvm-opt-report "/usr/bin/llvm-opt-report-$LLVM" \
        --slave /usr/bin/llvm-pdbutil llvm-pdbutil "/usr/bin/llvm-pdbutil-$LLVM" \
        --slave /usr/bin/llvm-profdata llvm-profdata "/usr/bin/llvm-profdata-$LLVM" \
        --slave /usr/bin/llvm-profgen llvm-profgen "/usr/bin/llvm-profgen-$LLVM" \
        --slave /usr/bin/llvm-ranlib llvm-ranlib "/usr/bin/llvm-ranlib-$LLVM" \
        --slave /usr/bin/llvm-rc llvm-rc "/usr/bin/llvm-rc-$LLVM" \
        --slave /usr/bin/llvm-readelf llvm-readelf "/usr/bin/llvm-readelf-$LLVM" \
        --slave /usr/bin/llvm-readobj llvm-readobj "/usr/bin/llvm-readobj-$LLVM" \
        --slave /usr/bin/llvm-reduce llvm-reduce "/usr/bin/llvm-reduce-$LLVM" \
        --slave /usr/bin/llvm-rtdyld llvm-rtdyld "/usr/bin/llvm-rtdyld-$LLVM" \
        --slave /usr/bin/llvm-size llvm-size "/usr/bin/llvm-size-$LLVM" \
        --slave /usr/bin/llvm-split llvm-split "/usr/bin/llvm-split-$LLVM" \
        --slave /usr/bin/llvm-stress llvm-stress "/usr/bin/llvm-stress-$LLVM" \
        --slave /usr/bin/llvm-strings llvm-strings "/usr/bin/llvm-strings-$LLVM" \
        --slave /usr/bin/llvm-strip llvm-strip "/usr/bin/llvm-strip-$LLVM" \
        --slave /usr/bin/llvm-symbolizer llvm-symbolizer "/usr/bin/llvm-symbolizer-$LLVM" \
        --slave /usr/bin/llvm-tblgen llvm-tblgen "/usr/bin/llvm-tblgen-$LLVM" \
        --slave /usr/bin/llvm-undname llvm-undname "/usr/bin/llvm-undname-$LLVM" \
        --slave /usr/bin/llvm-xray llvm-xray "/usr/bin/llvm-xray-$LLVM"
fi

if [[ -x "/usr/bin/clang-$LLVM" && ( ! -f "/usr/bin/clang" || $(update-alternatives --list clang) ) ]]; then
    # From https://gist.github.com/hcoona/4e6d681c054e8aa2b877f7363ca5d220
    update-alternatives --quiet \
        --install /usr/bin/clang clang "/usr/bin/clang-$LLVM" 10 \
        --slave /usr/bin/clang++ clang++ "/usr/bin/clang++-$LLVM" \
        --slave /usr/bin/clang-apply-replacements clang-apply-replacements "/usr/bin/clang-apply-replacements-$LLVM" \
        --slave /usr/bin/clang-change-namespace clang-change-namespace "/usr/bin/clang-change-namespace-$LLVM" \
        --slave /usr/bin/clang-check clang-check "/usr/bin/clang-check-$LLVM" \
        --slave /usr/bin/clang-cl clang-cl "/usr/bin/clang-cl-$LLVM" \
        --slave /usr/bin/clang-cpp clang-cpp "/usr/bin/clang-cpp-$LLVM" \
        --slave /usr/bin/clang-doc clang-doc "/usr/bin/clang-doc-$LLVM" \
        --slave /usr/bin/clang-extdef-mapping clang-extdef-mapping "/usr/bin/clang-extdef-mapping-$LLVM" \
        --slave /usr/bin/clang-format clang-format "/usr/bin/clang-format-$LLVM" \
        --slave /usr/bin/clang-format-diff clang-format-diff "/usr/bin/clang-format-diff-$LLVM" \
        --slave /usr/bin/clang-include-fixer clang-include-fixer "/usr/bin/clang-include-fixer-$LLVM" \
        --slave /usr/bin/clang-move clang-move "/usr/bin/clang-move-$LLVM" \
        --slave /usr/bin/clang-offload-bundler clang-offload-bundler "/usr/bin/clang-offload-bundler-$LLVM" \
        --slave /usr/bin/clang-offload-wrapper clang-offload-wrapper "/usr/bin/clang-offload-wrapper-$LLVM" \
        --slave /usr/bin/clang-query clang-query "/usr/bin/clang-query-$LLVM" \
        --slave /usr/bin/clang-refactor clang-refactor "/usr/bin/clang-refactor-$LLVM" \
        --slave /usr/bin/clang-rename clang-rename "/usr/bin/clang-rename-$LLVM" \
        --slave /usr/bin/clang-reorder-fields clang-reorder-fields "/usr/bin/clang-reorder-fields-$LLVM" \
        --slave /usr/bin/clang-scan-deps clang-scan-deps "/usr/bin/clang-scan-deps-$LLVM" \
        --slave /usr/bin/clang-tidy clang-tidy "/usr/bin/clang-tidy-$LLVM" \
        --slave /usr/bin/clang-tidy-diff.py clang-tidy-diff.py "/usr/bin/clang-tidy-diff-$LLVM.py"
fi

# Use lld or GNU gold for faster linking
if [ -x "/usr/bin/ld.lld" ]; then
    update-alternatives --install "/usr/bin/ld" "ld" "/usr/bin/ld.lld" 30
fi
if [ -x "/usr/bin/ld.gold" ]; then
    update-alternatives --install "/usr/bin/ld" "ld" "/usr/bin/ld.gold" 20
fi
if [ -x "/usr/bin/ld.bfd" ]; then
    update-alternatives --install "/usr/bin/ld" "ld" "/usr/bin/ld.bfd" 10
fi

if [ -d "/etc/gdb" ]; then
    echo 'set auto-load safe-path /' >> /etc/gdb/gdbinit
fi

