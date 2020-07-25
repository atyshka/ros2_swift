module @(package_name + "_c") [system] {
  @[for header in headers]
  header "@(header)"
  @[end for]
  export *
}
