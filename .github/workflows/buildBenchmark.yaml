# This workflow will build a Java project with Maven
# For more information see: https://help.github.com/actions/language-and-framework-guides/building-and-testing-java-with-maven

name: Build MooBench for Compilation Check

on: [push, pull_request, workflow_dispatch]

jobs:
  build:
    strategy:
        matrix:
          os: [ubuntu-latest]
          java: [ 1.8, 11, 17 ]
        fail-fast: false
    runs-on: ${{ matrix.os }}
    name: Java ${{ matrix.java }} OS ${{ matrix.os }} sample
    steps:
    - uses: actions/checkout@v2
    - name: Set up JDK ${{ matrix.java }}
      uses: actions/setup-java@v1
      with:
        java-version: ${{ matrix.java }}
    - name: Assemble Project
      run: ./gradlew assemble
