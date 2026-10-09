import Foundation
import Darwin

do { print(try S9CLI.run(Array(CommandLine.arguments.dropFirst()))) }
catch { print(S9CLI.failure(error)); exit(1) }
