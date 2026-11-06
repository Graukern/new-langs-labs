class TreeNode(
    val value: Int,
    val left: TreeNode? = null,
    val right: TreeNode? = null
)

fun maxDepth(root: TreeNode?): Int {
    if (root == null) return 0
    return 1 + maxOf(maxDepth(root.left), maxDepth(root.right))
}

fun main(args: Array<String>) {
    val tree = TreeNode(
        3,
        TreeNode(9),
        TreeNode(20, TreeNode(15), TreeNode(7))
    )
    println("Максимальная глубина: ${maxDepth(tree)}")
}
