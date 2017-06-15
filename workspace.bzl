# TensorFlow external dependencies that can be loaded in WORKSPACE files.

load("@io_bazel_rules_closure//closure/private:java_import_external.bzl", "java_import_external")
load("@io_bazel_rules_closure//closure:defs.bzl", "filegroup_external")
load("@io_bazel_rules_closure//closure:defs.bzl", "webfiles_external")
load("//third_party/gpus:cuda_configure.bzl", "cuda_configure")
load("//third_party/sycl:sycl_configure.bzl", "sycl_configure")


# Parse the bazel version string from `native.bazel_version`.
def _parse_bazel_version(bazel_version):
  # Remove commit from version.
  version = bazel_version.split(" ", 1)[0]

  # Split into (release, date) parts and only return the release
  # as a tuple of integers.
  parts = version.split('-', 1)

  # Turn "release" into a tuple of strings
  version_tuple = ()
  for number in parts[0].split('.'):
    version_tuple += (str(number),)
  return version_tuple

# Check that a specific bazel version is being used.
def check_version(bazel_version):
  if "bazel_version" not in dir(native):
    fail("\nCurrent Bazel version is lower than 0.2.1, expected at least %s\n" % bazel_version)
  elif not native.bazel_version:
    print("\nCurrent Bazel is not a release version, cannot check for compatibility.")
    print("Make sure that you are running at least Bazel %s.\n" % bazel_version)
  else:
    current_bazel_version = _parse_bazel_version(native.bazel_version)
    minimum_bazel_version = _parse_bazel_version(bazel_version)
    if minimum_bazel_version > current_bazel_version:
      fail("\nCurrent Bazel version is {}, expected at least {}\n".format(
          native.bazel_version, bazel_version))
  pass

def _repos_are_siblings():
  return Label("@foo//bar").workspace_root.startswith("../")

# Temporary workaround to support including TensorFlow as a submodule until this
# use-case is supported in the next Bazel release.
def _temp_workaround_http_archive_impl(repo_ctx):
   repo_ctx.template("BUILD", repo_ctx.attr.build_file,
                     {
                         "%prefix%" : ".." if _repos_are_siblings() else "external",
                         "%ws%": repo_ctx.attr.repository
                     }, False)
   repo_ctx.download_and_extract(repo_ctx.attr.urls, "", repo_ctx.attr.sha256,
                                 "", repo_ctx.attr.strip_prefix)

temp_workaround_http_archive = repository_rule(
   implementation=_temp_workaround_http_archive_impl,
   attrs = {
      "build_file": attr.label(),
      "repository": attr.string(),
      "urls": attr.string_list(default = []),
      "sha256": attr.string(default = ""),
      "strip_prefix": attr.string(default = ""),
   })

# If TensorFlow is linked as a submodule.
# path_prefix and tf_repo_name are no longer used.
def tf_workspace(path_prefix = "", tf_repo_name = ""):
  cuda_configure(name = "local_config_cuda")
  sycl_configure(name = "local_config_sycl")
  if path_prefix:
    print("path_prefix was specified to tf_workspace but is no longer used and will be removed in the future.")
  if tf_repo_name:
    print("tf_repo_name was specified to tf_workspace but is no longer used and will be removed in the future.")

  native.local_repository(
      name = "eigen_archive",
      path = "tensorflow_third_party/eigen_archive"
  )

  native.local_repository(
      name = "libxsmm_archive",
      path = "tensorflow_third_party/libxsmm_archive"
  )

  native.bind(
      name = "xsmm_avx",
      actual = "@libxsmm_archive//third_party:xsmm_avx",
  )

  native.local_repository(
      name = "com_googlesource_code_re2",
      path = "tensorflow_third_party/com_googlesource_code_re2"
  )

  native.local_repository(
      name = "gemmlowp",
      path = "tensorflow_third_party/gemmlowp"
  )

  native.local_repository(
      name = "farmhash_archive",
      path = "tensorflow_third_party/farmhash_archive"
  )

  native.bind(
      name = "farmhash",
      actual = "@farmhash//:farmhash",
  )

  native.local_repository(
      name = "highwayhash",
      path = "tensorflow_third_party/highwayhash"
  )

  native.local_repository(
      name = "nasm",
      path = "tensorflow_third_party/nasm"
  )

  native.local_repository(
      name = "jpeg",
      path = "tensorflow_third_party/jpeg"
  )

  native.local_repository(
      name = "png_archive",
      path = "tensorflow_third_party/png_archive"
  )

  native.local_repository(
      name = "gif_archive",
      path = "tensorflow_third_party/gif_archive"
  )

  native.local_repository(
      name = "six_archive",
      path = "tensorflow_third_party/six_archive"
  )

  native.local_repository(
      name = "org_pocoo_werkzeug",
      path = "tensorflow_third_party/org_pocoo_werkzeug"
  )

  native.bind(
      name = "six",
      actual = "@six_archive//:six",
  )

  native.local_repository(
      name = "protobuf",
      path = "tensorflow_third_party/protobuf"
  )

  native.local_repository(
      name = "gmock_archive",
      path = "tensorflow_third_party/gmock_archive"
  )

  native.bind(
      name = "gtest",
      actual = "@gmock_archive//:gtest",
  )

  native.bind(
      name = "gtest_main",
      actual = "@gmock_archive//:gtest_main",
  )

  native.bind(
      name = "python_headers",
      actual = str(Label("//util/python:python_headers")),
  )

  native.local_repository(
      name = "pcre",
      path = "tensorflow_third_party/pcre"
  )

  native.local_repository(
      name = "swig",
      path = "tensorflow_third_party/swig"
  )

  native.local_repository(
      name = "curl",
      path = "tensorflow_third_party/curl"
  )

  native.bind(
      name = "protobuf_clib",
      actual = "@protobuf//:protoc_lib",
  )

  native.bind(
      name = "protobuf_compiler",
      actual = "@protobuf//:protoc_lib",
  )

  native.local_repository(
      name = "grpc",
      path = "tensorflow_third_party/grpc"
  )

  native.bind(
      name = "grpc_cpp_plugin",
      actual = "@grpc//:grpc_cpp_plugin",
  )

  native.bind(
      name = "grpc_lib",
      actual = "@grpc//:grpc++_unsecure",
  )

  native.local_repository(
      name = "linenoise",
      path = "tensorflow_third_party/linenoise"
  )

  native.local_repository(
      name = "llvm",
      path = "tensorflow_third_party/llvm"
  )

  native.local_repository(
      name = "jsoncpp_git",
      path = "tensorflow_third_party/jsoncpp_git"
  )

  native.bind(
      name = "jsoncpp",
      actual = "@jsoncpp_git//:jsoncpp",
  )

  native.local_repository(
      name = "boringssl",
      path = "tensorflow_third_party/boringssl"
  )

  native.local_repository(
      name = "nanopb_git",
      path = "tensorflow_third_party/nanopb_git"
  )

  native.bind(
      name = "nanopb",
      actual = "@nanopb_git//:nanopb",
  )

  native.local_repository(
      name = "zlib_archive",
      path = "tensorflow_third_party/zlib_archive"
  )

  native.bind(
      name = "zlib",
      actual = "@zlib_archive//:zlib",
  )

  native.local_repository(
      name = "nccl_archive",
      path = "tensorflow_third_party/nccl_archive"
  )

  native.local_repository(
      name = "junit",
      path = "tensorflow_third_party/junit"
  )

  native.local_repository(
      name = "org_hamcrest_core",
      path = "tensorflow_third_party/org_hamcrest_core"
  )

  native.local_repository(
      name = "jemalloc",
      path = "tensorflow_third_party/jemalloc"
  )

  native.local_repository(
      name = "org_nodejs",
      path = "tensorflow_third_party/org_nodejs"
  )

  native.local_repository(
      name = "com_microsoft_typescript",
      path = "tensorflow_third_party/com_microsoft_typescript"
  )

  native.local_repository(
      name = "com_lodash",
      path = "tensorflow_third_party/com_lodash"
  )

  native.local_repository(
      name = "com_numericjs",
      path = "tensorflow_third_party/com_numericjs"
  )

  native.local_repository(
      name = "com_palantir_plottable",
      path = "tensorflow_third_party/com_palantir_plottable"
  )

  native.local_repository(
      name = "io_github_cpettitt_dagre",
      path = "tensorflow_third_party/io_github_cpettitt_dagre"
  )

  native.local_repository(
      name = "io_github_cpettitt_graphlib",
      path = "tensorflow_third_party/io_github_cpettitt_graphlib"
  )

  native.local_repository(
      name = "io_github_waylonflinn_weblas",
      path = "tensorflow_third_party/io_github_waylonflinn_weblas"
  )

  native.local_repository(
      name = "org_d3js",
      path = "tensorflow_third_party/org_d3js"
  )

  native.local_repository(
      name = "org_definitelytyped",
      path = "tensorflow_third_party/org_definitelytyped"
  )

  native.local_repository(
      name = "org_threejs",
      path = "tensorflow_third_party/org_threejs"
  )

  native.local_repository(
      name = "com_chaijs",
      path = "tensorflow_third_party/com_chaijs"
  )

  native.local_repository(
      name = "org_mochajs",
      path = "tensorflow_third_party/org_mochajs"
  )

  native.local_repository(
      name = "org_polymer_font_roboto",
      path = "tensorflow_third_party/org_polymer_font_roboto"
  )

  native.local_repository(
      name = "org_polymer_iron_a11y_announcer",
      path = "tensorflow_third_party/org_polymer_iron_a11y_announcer"
  )

  native.local_repository(
      name = "org_polymer_iron_a11y_keys_behavior",
      path = "tensorflow_third_party/org_polymer_iron_a11y_keys_behavior"
  )

  native.local_repository(
      name = "org_polymer_iron_ajax",
      path = "tensorflow_third_party/org_polymer_iron_ajax"
  )

  native.local_repository(
      name = "org_polymer_iron_autogrow_textarea",
      path = "tensorflow_third_party/org_polymer_iron_autogrow_textarea"
  )

  native.local_repository(
      name = "org_polymer_iron_behaviors",
      path = "tensorflow_third_party/org_polymer_iron_behaviors"
  )

  native.local_repository(
      name = "org_polymer_iron_checked_element_behavior",
      path = "tensorflow_third_party/org_polymer_iron_checked_element_behavior"
  )

  native.local_repository(
      name = "org_polymer_iron_collapse",
      path = "tensorflow_third_party/org_polymer_iron_collapse"
  )

  native.local_repository(
      name = "org_polymer_iron_demo_helpers",
      path = "tensorflow_third_party/org_polymer_iron_demo_helpers"
  )

  native.local_repository(
      name = "org_polymer_iron_dropdown",
      path = "tensorflow_third_party/org_polymer_iron_dropdown"
  )

  native.local_repository(
      name = "org_polymer_iron_fit_behavior",
      path = "tensorflow_third_party/org_polymer_iron_fit_behavior"
  )

  native.local_repository(
      name = "org_polymer_iron_flex_layout",
      path = "tensorflow_third_party/org_polymer_iron_flex_layout"
  )

  native.local_repository(
      name = "org_polymer_iron_form_element_behavior",
      path = "tensorflow_third_party/org_polymer_iron_form_element_behavior"
  )

  native.local_repository(
      name = "org_polymer_iron_icon",
      path = "tensorflow_third_party/org_polymer_iron_icon"
  )

  native.local_repository(
      name = "org_polymer_iron_icons",
      path = "tensorflow_third_party/org_polymer_iron_icons"
  )

  native.local_repository(
      name = "org_polymer_iron_iconset_svg",
      path = "tensorflow_third_party/org_polymer_iron_iconset_svg"
  )

  native.local_repository(
      name = "org_polymer_iron_input",
      path = "tensorflow_third_party/org_polymer_iron_input"
  )

  native.local_repository(
      name = "org_polymer_iron_list",
      path = "tensorflow_third_party/org_polymer_iron_list"
  )

  native.local_repository(
      name = "org_polymer_iron_menu_behavior",
      path = "tensorflow_third_party/org_polymer_iron_menu_behavior"
  )

  native.local_repository(
      name = "org_polymer_iron_meta",
      path = "tensorflow_third_party/org_polymer_iron_meta"
  )

  native.local_repository(
      name = "org_polymer_iron_overlay_behavior",
      path = "tensorflow_third_party/org_polymer_iron_overlay_behavior"
  )

  native.local_repository(
      name = "org_polymer_iron_range_behavior",
      path = "tensorflow_third_party/org_polymer_iron_range_behavior"
  )

  native.local_repository(
      name = "org_polymer_iron_resizable_behavior",
      path = "tensorflow_third_party/org_polymer_iron_resizable_behavior"
  )

  native.local_repository(
      name = "org_polymer_iron_scroll_target_behavior",
      path = "tensorflow_third_party/org_polymer_iron_scroll_target_behavior"
  )

  native.local_repository(
      name = "org_polymer_iron_selector",
      path = "tensorflow_third_party/org_polymer_iron_selector"
  )

  native.local_repository(
      name = "org_polymer_iron_validatable_behavior",
      path = "tensorflow_third_party/org_polymer_iron_validatable_behavior"
  )

  native.local_repository(
      name = "org_polymer_marked",
      path = "tensorflow_third_party/org_polymer_marked"
  )

  native.local_repository(
      name = "org_polymer_marked_element",
      path = "tensorflow_third_party/org_polymer_marked_element"
  )

  native.local_repository(
      name = "org_polymer_neon_animation",
      path = "tensorflow_third_party/org_polymer_neon_animation"
  )

  native.local_repository(
      name = "org_polymer_paper_behaviors",
      path = "tensorflow_third_party/org_polymer_paper_behaviors"
  )

  native.local_repository(
      name = "org_polymer_paper_button",
      path = "tensorflow_third_party/org_polymer_paper_button"
  )

  native.local_repository(
      name = "org_polymer_paper_checkbox",
      path = "tensorflow_third_party/org_polymer_paper_checkbox"
  )

  native.local_repository(
      name = "org_polymer_paper_dialog",
      path = "tensorflow_third_party/org_polymer_paper_dialog"
  )

  native.local_repository(
      name = "org_polymer_paper_dialog_behavior",
      path = "tensorflow_third_party/org_polymer_paper_dialog_behavior"
  )

  native.local_repository(
      name = "org_polymer_paper_dialog_scrollable",
      path = "tensorflow_third_party/org_polymer_paper_dialog_scrollable"
  )

  native.local_repository(
      name = "org_polymer_paper_dropdown_menu",
      path = "tensorflow_third_party/org_polymer_paper_dropdown_menu"
  )

  native.local_repository(
      name = "org_polymer_paper_header_panel",
      path = "tensorflow_third_party/org_polymer_paper_header_panel"
  )

  native.local_repository(
      name = "org_polymer_paper_icon_button",
      path = "tensorflow_third_party/org_polymer_paper_icon_button"
  )

  native.local_repository(
      name = "org_polymer_paper_input",
      path = "tensorflow_third_party/org_polymer_paper_input"
  )

  native.local_repository(
      name = "org_polymer_paper_item",
      path = "tensorflow_third_party/org_polymer_paper_item"
  )

  native.local_repository(
      name = "org_polymer_paper_listbox",
      path = "tensorflow_third_party/org_polymer_paper_listbox"
  )

  native.local_repository(
      name = "org_polymer_paper_material",
      path = "tensorflow_third_party/org_polymer_paper_material"
  )

  native.local_repository(
      name = "org_polymer_paper_menu",
      path = "tensorflow_third_party/org_polymer_paper_menu"
  )

  native.local_repository(
      name = "org_polymer_paper_menu_button",
      path = "tensorflow_third_party/org_polymer_paper_menu_button"
  )

  native.local_repository(
      name = "org_polymer_paper_progress",
      path = "tensorflow_third_party/org_polymer_paper_progress"
  )

  native.local_repository(
      name = "org_polymer_paper_radio_button",
      path = "tensorflow_third_party/org_polymer_paper_radio_button"
  )

  native.local_repository(
      name = "org_polymer_paper_radio_group",
      path = "tensorflow_third_party/org_polymer_paper_radio_group"
  )

  native.local_repository(
      name = "org_polymer_paper_ripple",
      path = "tensorflow_third_party/org_polymer_paper_ripple"
  )

  native.local_repository(
      name = "org_polymer_paper_slider",
      path = "tensorflow_third_party/org_polymer_paper_slider"
  )

  native.local_repository(
      name = "org_polymer_paper_spinner",
      path = "tensorflow_third_party/org_polymer_paper_spinner"
  )

  native.local_repository(
      name = "org_polymer_paper_styles",
      path = "tensorflow_third_party/org_polymer_paper_styles"
  )

  native.local_repository(
      name = "org_polymer_paper_tabs",
      path = "tensorflow_third_party/org_polymer_paper_tabs"
  )

  native.local_repository(
      name = "org_polymer_paper_toast",
      path = "tensorflow_third_party/org_polymer_paper_toast"
  )

  native.local_repository(
      name = "org_polymer_paper_toggle_button",
      path = "tensorflow_third_party/org_polymer_paper_toggle_button"
  )

  native.local_repository(
      name = "org_polymer_paper_toolbar",
      path = "tensorflow_third_party/org_polymer_paper_toolbar"
  )

  native.local_repository(
      name = "org_polymer_paper_tooltip",
      path = "tensorflow_third_party/org_polymer_paper_tooltip"
  )

  native.local_repository(
      name = "org_polymer",
      path = "tensorflow_third_party/org_polymer"
  )

  native.local_repository(
      name = "org_polymer_prism",
      path = "tensorflow_third_party/org_polymer_prism"
  )

  native.local_repository(
      name = "org_polymer_prism_element",
      path = "tensorflow_third_party/org_polymer_prism_element"
  )

  native.local_repository(
      name = "org_polymer_promise_polyfill",
      path = "tensorflow_third_party/org_polymer_promise_polyfill"
  )

  native.local_repository(
      name = "org_polymer_web_animations_js",
      path = "tensorflow_third_party/org_polymer_web_animations_js"
  )

  native.local_repository(
      name = "org_polymer_webcomponentsjs",
      path = "tensorflow_third_party/org_polymer_webcomponentsjs"
  )

