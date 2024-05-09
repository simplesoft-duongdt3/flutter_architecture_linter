import 'package:analyzer/dart/analysis/results.dart';
import 'package:architecture_linter/src/configuration/lint_severity.dart';
import 'package:test/test.dart';

import '../../../helpers/file_parse_helper.dart';
import '../../../mocks/architecture_analyzer.dart';
import '../../../mocks/config.dart';

void main() {
  const domainPath = '/domain/';
  const infrastructurePath = '/infrastructure/';
  const presentationPath = '/presentation/';

  final architectureAnalyzerImports =
      ArchitectureAnalyzerMocks.baseArchitectureAnalyzer;
  final config = ConfigMocks.baseConfigMock;

  test(
    'Tests if analyzer will return three lints for domain_class.dart',
    () async {
      final domainClassUnit =
          await FileParseHelper.parseTestFile('${domainPath}domain_class.dart')
              as ResolvedUnitResult;

      final lints = architectureAnalyzerImports.runAnalysis(
        domainClassUnit,
        config,
      );
      expect(lints.length, 4);
    },
  );

  test(
    'Tests if analyzer will respect // ignore and return one lint',
    () async {
      final domainClassUnit = await FileParseHelper.parseTestFile(
        '${domainPath}domain_class_ignore.dart',
      ) as ResolvedUnitResult;

      final lints = architectureAnalyzerImports.runAnalysis(
        domainClassUnit,
        config,
      );
      expect(lints.length, 1);
    },
  );

  test(
    'Tests if analyzer will respect // ignore_for_file and return 0 lints',
    () async {
      final domainClassUnit = await FileParseHelper.parseTestFile(
        '${domainPath}domain_class_ignore_for_file.dart',
      ) as ResolvedUnitResult;

      final lints = architectureAnalyzerImports.runAnalysis(
        domainClassUnit,
        config,
      );
      expect(lints.length, 0);
    },
  );

  test(
    'Tests if analyzer will respect lint_severity config',
    () async {
      final domainClassUnit =
          await FileParseHelper.parseTestFile('${domainPath}domain_class.dart')
              as ResolvedUnitResult;

      final lints = architectureAnalyzerImports.runAnalysis(
        domainClassUnit,
        config,
      );
      final firstLintSeverity = lints.first;

      expect(
        firstLintSeverity.severity,
        config.lintSeverity.analysisErrorSeverity,
      );
    },
  );

  test(
    'Tests if analyzer will respect banned layer severity config',
    () async {
      final domainClassUnit = await FileParseHelper.parseTestFile(
        '${infrastructurePath}infrastructure_class.dart',
      ) as ResolvedUnitResult;

      final lints = architectureAnalyzerImports.runAnalysis(
        domainClassUnit,
        config,
      );
      final firstLintSeverity = lints.first;

      expect(
        firstLintSeverity.severity,
        config.bannedImportSeverities.entries.first.value.analysisErrorSeverity,
      );
    },
  );

  test(
    'Tests if analyzer will not return lint for file that matches layer regex',
    () async {
      final presentationClassUnit = await FileParseHelper.parseTestFile(
        '${presentationPath}presentation_class.dart',
      ) as ResolvedUnitResult;

      final lints = architectureAnalyzerImports.runAnalysis(
        presentationClassUnit,
        config,
      );

      print(lints);

      expect(lints.length, 0);
    },
  );
}
