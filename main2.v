import os

fn main() {
	current_dir := os.getwd()
	list_dir := os.ls(current_dir) ?
	println(list_dir)
}
