#!/bin/sh

# Compatible with Linux and macOS.

set -eu

usage() {
    printf 'Usage: %s [-r|--recursive] [directory]\n' "$(basename "$0")"
}

recursive=0
target_directory=

while [ "$#" -gt 0 ]; do
    case $1 in
        -r|--recursive)
            recursive=1
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        --)
            shift
            if [ "$#" -gt 1 ] || { [ "$#" -eq 1 ] && [ -n "$target_directory" ]; }; then
                printf 'Only one directory may be provided.\n' >&2
                usage >&2
                exit 2
            fi
            if [ "$#" -eq 1 ]; then
                target_directory=$1
                shift
            fi
            break
            ;;
        -*)
            printf 'Unknown option: %s\n' "$1" >&2
            usage >&2
            exit 2
            ;;
        *)
            if [ -n "$target_directory" ]; then
                printf 'Only one directory may be provided.\n' >&2
                usage >&2
                exit 2
            fi
            target_directory=$1
            ;;
    esac
    shift
done

if [ "$#" -gt 0 ]; then
    printf 'Only one directory may be provided.\n' >&2
    usage >&2
    exit 2
fi

script_directory=$(CDPATH= cd "$(dirname "$0")" && pwd -P)
script_path=$script_directory/$(basename "$0")

if [ -z "$target_directory" ]; then
    printf 'Enter the directory to list (press Enter to use the script directory): '
    IFS= read -r target_directory || target_directory=
    if [ -z "$target_directory" ]; then
        target_directory=$script_directory
    fi
fi

if [ ! -d "$target_directory" ]; then
    printf 'Not a directory: %s\n' "$target_directory" >&2
    exit 1
fi

case $target_directory in
    -*) target_directory=./$target_directory ;;
esac

target_directory=$(CDPATH= cd "$target_directory" && pwd -P)
output_path=$script_directory/file-list.txt

if [ -d "$output_path" ]; then
    printf 'Cannot create file-list.txt because a directory with that name already exists beside the script.\n' >&2
    exit 1
fi

raw_list=$(mktemp "$script_directory/.file-list.raw.XXXXXX")
sorted_list=$(mktemp "$script_directory/.file-list.sorted.XXXXXX")

cleanup() {
    rm -f "$raw_list" "$sorted_list"
}
trap cleanup EXIT HUP INT TERM

if [ "$recursive" -eq 1 ]; then
    find "$target_directory" -type f \
        ! -path "$script_path" \
        ! -path "$output_path" \
        ! -path "$raw_list" \
        ! -path "$sorted_list" \
        -exec basename {} \; > "$raw_list"
else
    find "$target_directory" ! -path "$target_directory" -prune -type f \
        ! -path "$script_path" \
        ! -path "$output_path" \
        ! -path "$raw_list" \
        ! -path "$sorted_list" \
        -exec basename {} \; > "$raw_list"
fi

LC_ALL=C sort "$raw_list" > "$sorted_list"
mv -f "$sorted_list" "$output_path"

count=$(wc -l < "$output_path" | tr -d '[:space:]')
printf 'Wrote %s file name(s) to: %s\n' "$count" "$output_path"
