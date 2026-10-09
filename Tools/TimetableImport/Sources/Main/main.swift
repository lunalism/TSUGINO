import Foundation
import Darwin

do { print(try ImportCLI.run(Array(CommandLine.arguments.dropFirst()))) }
catch { print(ImportCLI.failure(error)); exit(1) }
