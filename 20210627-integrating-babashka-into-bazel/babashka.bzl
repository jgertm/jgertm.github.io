# babashka.bzl
def _bb_toolchain(ctx):
    return platform_common.ToolchainInfo(
        bb = ctx.executable.bb,
    )

bb_toolchain = rule(
    implementation = _bb_toolchain,
    attrs = {
        "bb": attr.label(
            executable = True,
            allow_single_file = True,
            cfg = "exec",
        ),
    },
)

def _bb_genrule_impl(ctx):
    toolchain = ctx.toolchains["//:babashka_toolchain"]   # (1)
    ctx.actions.run(
        inputs = [ctx.file.script] + ctx.files.data,
        outputs = [ctx.outputs.out],
        executable = toolchain.bb,                        # (2)
        arguments = [
            ctx.file.script.path,
            """{{
            :out-file "{out_file}"
            :data [{data}]
            }}""".format(
                out_file = ctx.outputs.out.path,
                data = " ".join(["\"{}\"".format(data.path) for data in ctx.files.data]),
            ),
        ],
    )

bb_genrule = rule(
    implementation = _bb_genrule_impl,
    attrs = {
        "script": attr.label(allow_single_file = [".clj"], mandatory = True),
        "out": attr.output(mandatory = True),
        "data": attr.label_list(allow_files = True),
    },
    toolchains = ["//:babashka_toolchain"],               # (3)
)

def _bb_binary_impl(ctx):
    toolchain = ctx.toolchains["//:babashka_toolchain"] 
    executable = ctx.actions.declare_file(ctx.label.name)
    ctx.actions.write(
        output = executable,
        is_executable = True,
        content = """
        set -x
        exec {bb} {src} {arguments} "$@"
        """.format(
            bb = toolchain.bb.path,
            src = ctx.file.src.path,
            arguments = " ".join(ctx.attr.arguments),
        ),
    )

    return DefaultInfo(
        executable = executable,
        runfiles = ctx.runfiles(files = [toolchain.bb, ctx.file.src]),
    )

EXEC_ATTRS = {
    "src": attr.label(
        allow_single_file = [".clj"],
        mandatory = True,
    ),
    "arguments": attr.string_list(),
}

bb_binary = rule(
    implementation = _bb_binary_impl,
    executable = True,
    attrs = EXEC_ATTRS,
    toolchains = ["//:babashka_toolchain"],
)

bb_test = rule(
    implementation = _bb_binary_impl,
    test = True,
    attrs = EXEC_ATTRS,
    toolchains = ["//:babashka_toolchain"],
)
