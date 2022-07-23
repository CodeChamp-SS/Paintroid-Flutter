///
import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;
@$core.Deprecated('Use serializablePaintDescriptor instead')
const SerializablePaint$json = const {
  '1': 'SerializablePaint',
  '2': const [
    const {'1': 'color', '3': 1, '4': 1, '5': 13, '10': 'color'},
    const {'1': 'strokeWidth', '3': 2, '4': 1, '5': 2, '10': 'strokeWidth'},
    const {'1': 'cap', '3': 3, '4': 1, '5': 14, '6': '.SerializablePaint.StrokeCap', '10': 'cap'},
    const {'1': 'style', '3': 4, '4': 1, '5': 14, '6': '.SerializablePaint.PaintingStyle', '10': 'style'},
  ],
  '4': const [SerializablePaint_StrokeCap$json, SerializablePaint_PaintingStyle$json],
};

@$core.Deprecated('Use serializablePaintDescriptor instead')
const SerializablePaint_StrokeCap$json = const {
  '1': 'StrokeCap',
  '2': const [
    const {'1': 'ROUND', '2': 0},
    const {'1': 'BUTT', '2': 1},
    const {'1': 'SQUARE', '2': 2},
  ],
};

@$core.Deprecated('Use serializablePaintDescriptor instead')
const SerializablePaint_PaintingStyle$json = const {
  '1': 'PaintingStyle',
  '2': const [
    const {'1': 'FILL', '2': 0},
    const {'1': 'STROKE', '2': 1},
  ],
};

/// Descriptor for `SerializablePaint`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List serializablePaintDescriptor = $convert.base64Decode('ChFTZXJpYWxpemFibGVQYWludBIUCgVjb2xvchgBIAEoDVIFY29sb3ISIAoLc3Ryb2tlV2lkdGgYAiABKAJSC3N0cm9rZVdpZHRoEi4KA2NhcBgDIAEoDjIcLlNlcmlhbGl6YWJsZVBhaW50LlN0cm9rZUNhcFIDY2FwEjYKBXN0eWxlGAQgASgOMiAuU2VyaWFsaXphYmxlUGFpbnQuUGFpbnRpbmdTdHlsZVIFc3R5bGUiLAoJU3Ryb2tlQ2FwEgkKBVJPVU5EEAASCAoEQlVUVBABEgoKBlNRVUFSRRACIiUKDVBhaW50aW5nU3R5bGUSCAoERklMTBAAEgoKBlNUUk9LRRAB');
