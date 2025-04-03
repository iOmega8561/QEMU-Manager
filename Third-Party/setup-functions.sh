if [[ -z "${SCRIPTPATH}" ]]; then
    exit 1
fi

merge_lipo_universal() {

    local product_name="$1"
    local product_path="${SCRIPTPATH}/$1"
    
    # Create universal product folder
    mkdir -p "${product_path}/lib" "${product_path}/include"
    
    find "${product_path}-arm64" -type f | while read -r src_file; do
    
        # Compute relative path from arm64 root
        local rel_path="${src_file#${product_path}-arm64/}"
    
        # Define counterpart and destination paths
        local x86_file="${product_path}-x86_64/${rel_path}"
        local dst_file="${product_path}/${rel_path}"
    
        # Make sure destination directory exists
        mkdir -p "$(dirname "$dst_file")"
    
        # Merge with lipo or copy depending on type
        if [[ "$src_file" == *.a || "$src_file" == *.dylib ]] ||
           ([ -x "$src_file" ] && file "$src_file" | grep -q 'Mach-O'); then
        
            echo "Merging: $rel_path"
            lipo -create "$src_file" "$x86_file" -output "$dst_file"
            
        else
            echo "Copying: $rel_path"
            cp "$src_file" "$dst_file"
        fi
    done
    
    # Fixing the PKGCONFIG prefix path for universal build
    for pcfile in "${product_path}/lib/pkgconfig"/*.pc; do
        sed -i '' -e "s|^prefix=.*|prefix=${product_path}|" "$pcfile"
    done
    
    rm -fr "${product_path}-arm64" "${product_path}-x86_64"
}

build_meson_universal() {

    local product_name="$1" && shift 1
    local product_meson_args=("$@")

    cd "${product_name}-src"

    for arch in "arm64" "x86_64"; do
    
        local build_dir="build-${arch}"
        local cross_file="${SCRIPTPATH}/${arch}-cross.txt"
        local prefix_path="${SCRIPTPATH}/${product_name}-${arch}"
    
        meson setup "${build_dir}" \
            --cross-file="${cross_file}" \
            --prefix="${prefix_path}" \
            ${product_meson_args[@]}
    
        ninja -C "${build_dir}"
        mkdir "${prefix_path}"
        ninja -C "${build_dir}" install
        
    done; cd ..
}

build_qemu_universal() {

    local qemu_feature_arguments=("$@")
    
    cd "qemu-src"

    for conf in "arm64 aarch64" "x86_64 x86_64"; do
    
        read -r arch cpu <<< "$conf"
        
        local build_dir="build-${arch}"
        local prefix_path="${SCRIPTPATH}/QEMU-${arch}"
        local host="${arch}-apple-darwin"

        mkdir -p "$build_dir" && cd "$build_dir"

        CFLAGS="-g -O2 -arch ${arch}" \
        LDFLAGS="-g -O2 -arch ${arch}" \
        OBJCFLAGS="-g -O2 -arch ${arch}" \
        OBJC_LDFLAGS="-g -O2 -arch ${arch}" \
        ../configure \
            --prefix="${prefix_path}" \
            --host="${host}" \
            --datadir="./share" \
            --cross-prefix="" \
            --cpu="${cpu}" \
            ${qemu_feature_arguments[@]}

        make -j"$(sysctl -n hw.logicalcpu)"
        mkdir "${prefix_path}"
        make install && cd ..
    
    done; cd ..
}
