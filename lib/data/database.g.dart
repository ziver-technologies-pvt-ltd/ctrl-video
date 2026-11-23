// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $DownloadRecordsTable extends DownloadRecords
    with TableInfo<$DownloadRecordsTable, DownloadRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _platformMeta = const VerificationMeta(
    'platform',
  );
  @override
  late final GeneratedColumn<String> platform = GeneratedColumn<String>(
    'platform',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _thumbnailUrlMeta = const VerificationMeta(
    'thumbnailUrl',
  );
  @override
  late final GeneratedColumn<String> thumbnailUrl = GeneratedColumn<String>(
    'thumbnail_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _formatLabelMeta = const VerificationMeta(
    'formatLabel',
  );
  @override
  late final GeneratedColumn<String> formatLabel = GeneratedColumn<String>(
    'format_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _errorCodeMeta = const VerificationMeta(
    'errorCode',
  );
  @override
  late final GeneratedColumn<String> errorCode = GeneratedColumn<String>(
    'error_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _videoFormatIdMeta = const VerificationMeta(
    'videoFormatId',
  );
  @override
  late final GeneratedColumn<String> videoFormatId = GeneratedColumn<String>(
    'video_format_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _audioFormatIdMeta = const VerificationMeta(
    'audioFormatId',
  );
  @override
  late final GeneratedColumn<String> audioFormatId = GeneratedColumn<String>(
    'audio_format_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _containerMeta = const VerificationMeta(
    'container',
  );
  @override
  late final GeneratedColumn<String> container = GeneratedColumn<String>(
    'container',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _audioCodecMeta = const VerificationMeta(
    'audioCodec',
  );
  @override
  late final GeneratedColumn<String> audioCodec = GeneratedColumn<String>(
    'audio_codec',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _trimStartMsMeta = const VerificationMeta(
    'trimStartMs',
  );
  @override
  late final GeneratedColumn<int> trimStartMs = GeneratedColumn<int>(
    'trim_start_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _trimEndMsMeta = const VerificationMeta(
    'trimEndMs',
  );
  @override
  late final GeneratedColumn<int> trimEndMs = GeneratedColumn<int>(
    'trim_end_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _trimModeMeta = const VerificationMeta(
    'trimMode',
  );
  @override
  late final GeneratedColumn<String> trimMode = GeneratedColumn<String>(
    'trim_mode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    url,
    platform,
    title,
    thumbnailUrl,
    filePath,
    formatLabel,
    sizeBytes,
    status,
    errorCode,
    createdAt,
    completedAt,
    videoFormatId,
    audioFormatId,
    container,
    audioCodec,
    trimStartMs,
    trimEndMs,
    trimMode,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'download_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<DownloadRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('platform')) {
      context.handle(
        _platformMeta,
        platform.isAcceptableOrUnknown(data['platform']!, _platformMeta),
      );
    } else if (isInserting) {
      context.missing(_platformMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('thumbnail_url')) {
      context.handle(
        _thumbnailUrlMeta,
        thumbnailUrl.isAcceptableOrUnknown(
          data['thumbnail_url']!,
          _thumbnailUrlMeta,
        ),
      );
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    }
    if (data.containsKey('format_label')) {
      context.handle(
        _formatLabelMeta,
        formatLabel.isAcceptableOrUnknown(
          data['format_label']!,
          _formatLabelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_formatLabelMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('error_code')) {
      context.handle(
        _errorCodeMeta,
        errorCode.isAcceptableOrUnknown(data['error_code']!, _errorCodeMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('video_format_id')) {
      context.handle(
        _videoFormatIdMeta,
        videoFormatId.isAcceptableOrUnknown(
          data['video_format_id']!,
          _videoFormatIdMeta,
        ),
      );
    }
    if (data.containsKey('audio_format_id')) {
      context.handle(
        _audioFormatIdMeta,
        audioFormatId.isAcceptableOrUnknown(
          data['audio_format_id']!,
          _audioFormatIdMeta,
        ),
      );
    }
    if (data.containsKey('container')) {
      context.handle(
        _containerMeta,
        container.isAcceptableOrUnknown(data['container']!, _containerMeta),
      );
    }
    if (data.containsKey('audio_codec')) {
      context.handle(
        _audioCodecMeta,
        audioCodec.isAcceptableOrUnknown(data['audio_codec']!, _audioCodecMeta),
      );
    }
    if (data.containsKey('trim_start_ms')) {
      context.handle(
        _trimStartMsMeta,
        trimStartMs.isAcceptableOrUnknown(
          data['trim_start_ms']!,
          _trimStartMsMeta,
        ),
      );
    }
    if (data.containsKey('trim_end_ms')) {
      context.handle(
        _trimEndMsMeta,
        trimEndMs.isAcceptableOrUnknown(data['trim_end_ms']!, _trimEndMsMeta),
      );
    }
    if (data.containsKey('trim_mode')) {
      context.handle(
        _trimModeMeta,
        trimMode.isAcceptableOrUnknown(data['trim_mode']!, _trimModeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DownloadRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      platform: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}platform'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      thumbnailUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_url'],
      ),
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      ),
      formatLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}format_label'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      errorCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_code'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      videoFormatId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}video_format_id'],
      ),
      audioFormatId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_format_id'],
      ),
      container: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}container'],
      ),
      audioCodec: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_codec'],
      ),
      trimStartMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}trim_start_ms'],
      ),
      trimEndMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}trim_end_ms'],
      ),
      trimMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trim_mode'],
      ),
    );
  }

  @override
  $DownloadRecordsTable createAlias(String alias) {
    return $DownloadRecordsTable(attachedDatabase, alias);
  }
}

class DownloadRecord extends DataClass implements Insertable<DownloadRecord> {
  final int id;
  final String url;
  final String platform;
  final String title;
  final String? thumbnailUrl;
  final String? filePath;
  final String formatLabel;
  final int? sizeBytes;
  final String status;
  final String? errorCode;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? videoFormatId;
  final String? audioFormatId;
  final String? container;
  final String? audioCodec;
  final int? trimStartMs;
  final int? trimEndMs;
  final String? trimMode;
  const DownloadRecord({
    required this.id,
    required this.url,
    required this.platform,
    required this.title,
    this.thumbnailUrl,
    this.filePath,
    required this.formatLabel,
    this.sizeBytes,
    required this.status,
    this.errorCode,
    required this.createdAt,
    this.completedAt,
    this.videoFormatId,
    this.audioFormatId,
    this.container,
    this.audioCodec,
    this.trimStartMs,
    this.trimEndMs,
    this.trimMode,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['url'] = Variable<String>(url);
    map['platform'] = Variable<String>(platform);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || thumbnailUrl != null) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl);
    }
    if (!nullToAbsent || filePath != null) {
      map['file_path'] = Variable<String>(filePath);
    }
    map['format_label'] = Variable<String>(formatLabel);
    if (!nullToAbsent || sizeBytes != null) {
      map['size_bytes'] = Variable<int>(sizeBytes);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || errorCode != null) {
      map['error_code'] = Variable<String>(errorCode);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || videoFormatId != null) {
      map['video_format_id'] = Variable<String>(videoFormatId);
    }
    if (!nullToAbsent || audioFormatId != null) {
      map['audio_format_id'] = Variable<String>(audioFormatId);
    }
    if (!nullToAbsent || container != null) {
      map['container'] = Variable<String>(container);
    }
    if (!nullToAbsent || audioCodec != null) {
      map['audio_codec'] = Variable<String>(audioCodec);
    }
    if (!nullToAbsent || trimStartMs != null) {
      map['trim_start_ms'] = Variable<int>(trimStartMs);
    }
    if (!nullToAbsent || trimEndMs != null) {
      map['trim_end_ms'] = Variable<int>(trimEndMs);
    }
    if (!nullToAbsent || trimMode != null) {
      map['trim_mode'] = Variable<String>(trimMode);
    }
    return map;
  }

  DownloadRecordsCompanion toCompanion(bool nullToAbsent) {
    return DownloadRecordsCompanion(
      id: Value(id),
      url: Value(url),
      platform: Value(platform),
      title: Value(title),
      thumbnailUrl: thumbnailUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailUrl),
      filePath: filePath == null && nullToAbsent
          ? const Value.absent()
          : Value(filePath),
      formatLabel: Value(formatLabel),
      sizeBytes: sizeBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(sizeBytes),
      status: Value(status),
      errorCode: errorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(errorCode),
      createdAt: Value(createdAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      videoFormatId: videoFormatId == null && nullToAbsent
          ? const Value.absent()
          : Value(videoFormatId),
      audioFormatId: audioFormatId == null && nullToAbsent
          ? const Value.absent()
          : Value(audioFormatId),
      container: container == null && nullToAbsent
          ? const Value.absent()
          : Value(container),
      audioCodec: audioCodec == null && nullToAbsent
          ? const Value.absent()
          : Value(audioCodec),
      trimStartMs: trimStartMs == null && nullToAbsent
          ? const Value.absent()
          : Value(trimStartMs),
      trimEndMs: trimEndMs == null && nullToAbsent
          ? const Value.absent()
          : Value(trimEndMs),
      trimMode: trimMode == null && nullToAbsent
          ? const Value.absent()
          : Value(trimMode),
    );
  }

  factory DownloadRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadRecord(
      id: serializer.fromJson<int>(json['id']),
      url: serializer.fromJson<String>(json['url']),
      platform: serializer.fromJson<String>(json['platform']),
      title: serializer.fromJson<String>(json['title']),
      thumbnailUrl: serializer.fromJson<String?>(json['thumbnailUrl']),
      filePath: serializer.fromJson<String?>(json['filePath']),
      formatLabel: serializer.fromJson<String>(json['formatLabel']),
      sizeBytes: serializer.fromJson<int?>(json['sizeBytes']),
      status: serializer.fromJson<String>(json['status']),
      errorCode: serializer.fromJson<String?>(json['errorCode']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      videoFormatId: serializer.fromJson<String?>(json['videoFormatId']),
      audioFormatId: serializer.fromJson<String?>(json['audioFormatId']),
      container: serializer.fromJson<String?>(json['container']),
      audioCodec: serializer.fromJson<String?>(json['audioCodec']),
      trimStartMs: serializer.fromJson<int?>(json['trimStartMs']),
      trimEndMs: serializer.fromJson<int?>(json['trimEndMs']),
      trimMode: serializer.fromJson<String?>(json['trimMode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'url': serializer.toJson<String>(url),
      'platform': serializer.toJson<String>(platform),
      'title': serializer.toJson<String>(title),
      'thumbnailUrl': serializer.toJson<String?>(thumbnailUrl),
      'filePath': serializer.toJson<String?>(filePath),
      'formatLabel': serializer.toJson<String>(formatLabel),
      'sizeBytes': serializer.toJson<int?>(sizeBytes),
      'status': serializer.toJson<String>(status),
      'errorCode': serializer.toJson<String?>(errorCode),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'videoFormatId': serializer.toJson<String?>(videoFormatId),
      'audioFormatId': serializer.toJson<String?>(audioFormatId),
      'container': serializer.toJson<String?>(container),
      'audioCodec': serializer.toJson<String?>(audioCodec),
      'trimStartMs': serializer.toJson<int?>(trimStartMs),
      'trimEndMs': serializer.toJson<int?>(trimEndMs),
      'trimMode': serializer.toJson<String?>(trimMode),
    };
  }

  DownloadRecord copyWith({
    int? id,
    String? url,
    String? platform,
    String? title,
    Value<String?> thumbnailUrl = const Value.absent(),
    Value<String?> filePath = const Value.absent(),
    String? formatLabel,
    Value<int?> sizeBytes = const Value.absent(),
    String? status,
    Value<String?> errorCode = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> completedAt = const Value.absent(),
    Value<String?> videoFormatId = const Value.absent(),
    Value<String?> audioFormatId = const Value.absent(),
    Value<String?> container = const Value.absent(),
    Value<String?> audioCodec = const Value.absent(),
    Value<int?> trimStartMs = const Value.absent(),
    Value<int?> trimEndMs = const Value.absent(),
    Value<String?> trimMode = const Value.absent(),
  }) => DownloadRecord(
    id: id ?? this.id,
    url: url ?? this.url,
    platform: platform ?? this.platform,
    title: title ?? this.title,
    thumbnailUrl: thumbnailUrl.present ? thumbnailUrl.value : this.thumbnailUrl,
    filePath: filePath.present ? filePath.value : this.filePath,
    formatLabel: formatLabel ?? this.formatLabel,
    sizeBytes: sizeBytes.present ? sizeBytes.value : this.sizeBytes,
    status: status ?? this.status,
    errorCode: errorCode.present ? errorCode.value : this.errorCode,
    createdAt: createdAt ?? this.createdAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    videoFormatId: videoFormatId.present
        ? videoFormatId.value
        : this.videoFormatId,
    audioFormatId: audioFormatId.present
        ? audioFormatId.value
        : this.audioFormatId,
    container: container.present ? container.value : this.container,
    audioCodec: audioCodec.present ? audioCodec.value : this.audioCodec,
    trimStartMs: trimStartMs.present ? trimStartMs.value : this.trimStartMs,
    trimEndMs: trimEndMs.present ? trimEndMs.value : this.trimEndMs,
    trimMode: trimMode.present ? trimMode.value : this.trimMode,
  );
  DownloadRecord copyWithCompanion(DownloadRecordsCompanion data) {
    return DownloadRecord(
      id: data.id.present ? data.id.value : this.id,
      url: data.url.present ? data.url.value : this.url,
      platform: data.platform.present ? data.platform.value : this.platform,
      title: data.title.present ? data.title.value : this.title,
      thumbnailUrl: data.thumbnailUrl.present
          ? data.thumbnailUrl.value
          : this.thumbnailUrl,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      formatLabel: data.formatLabel.present
          ? data.formatLabel.value
          : this.formatLabel,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      status: data.status.present ? data.status.value : this.status,
      errorCode: data.errorCode.present ? data.errorCode.value : this.errorCode,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      videoFormatId: data.videoFormatId.present
          ? data.videoFormatId.value
          : this.videoFormatId,
      audioFormatId: data.audioFormatId.present
          ? data.audioFormatId.value
          : this.audioFormatId,
      container: data.container.present ? data.container.value : this.container,
      audioCodec: data.audioCodec.present
          ? data.audioCodec.value
          : this.audioCodec,
      trimStartMs: data.trimStartMs.present
          ? data.trimStartMs.value
          : this.trimStartMs,
      trimEndMs: data.trimEndMs.present ? data.trimEndMs.value : this.trimEndMs,
      trimMode: data.trimMode.present ? data.trimMode.value : this.trimMode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadRecord(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('platform: $platform, ')
          ..write('title: $title, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('filePath: $filePath, ')
          ..write('formatLabel: $formatLabel, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('status: $status, ')
          ..write('errorCode: $errorCode, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('videoFormatId: $videoFormatId, ')
          ..write('audioFormatId: $audioFormatId, ')
          ..write('container: $container, ')
          ..write('audioCodec: $audioCodec, ')
          ..write('trimStartMs: $trimStartMs, ')
          ..write('trimEndMs: $trimEndMs, ')
          ..write('trimMode: $trimMode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    url,
    platform,
    title,
    thumbnailUrl,
    filePath,
    formatLabel,
    sizeBytes,
    status,
    errorCode,
    createdAt,
    completedAt,
    videoFormatId,
    audioFormatId,
    container,
    audioCodec,
    trimStartMs,
    trimEndMs,
    trimMode,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadRecord &&
          other.id == this.id &&
          other.url == this.url &&
          other.platform == this.platform &&
          other.title == this.title &&
          other.thumbnailUrl == this.thumbnailUrl &&
          other.filePath == this.filePath &&
          other.formatLabel == this.formatLabel &&
          other.sizeBytes == this.sizeBytes &&
          other.status == this.status &&
          other.errorCode == this.errorCode &&
          other.createdAt == this.createdAt &&
          other.completedAt == this.completedAt &&
          other.videoFormatId == this.videoFormatId &&
          other.audioFormatId == this.audioFormatId &&
          other.container == this.container &&
          other.audioCodec == this.audioCodec &&
          other.trimStartMs == this.trimStartMs &&
          other.trimEndMs == this.trimEndMs &&
          other.trimMode == this.trimMode);
}

class DownloadRecordsCompanion extends UpdateCompanion<DownloadRecord> {
  final Value<int> id;
  final Value<String> url;
  final Value<String> platform;
  final Value<String> title;
  final Value<String?> thumbnailUrl;
  final Value<String?> filePath;
  final Value<String> formatLabel;
  final Value<int?> sizeBytes;
  final Value<String> status;
  final Value<String?> errorCode;
  final Value<DateTime> createdAt;
  final Value<DateTime?> completedAt;
  final Value<String?> videoFormatId;
  final Value<String?> audioFormatId;
  final Value<String?> container;
  final Value<String?> audioCodec;
  final Value<int?> trimStartMs;
  final Value<int?> trimEndMs;
  final Value<String?> trimMode;
  const DownloadRecordsCompanion({
    this.id = const Value.absent(),
    this.url = const Value.absent(),
    this.platform = const Value.absent(),
    this.title = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.filePath = const Value.absent(),
    this.formatLabel = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.status = const Value.absent(),
    this.errorCode = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.videoFormatId = const Value.absent(),
    this.audioFormatId = const Value.absent(),
    this.container = const Value.absent(),
    this.audioCodec = const Value.absent(),
    this.trimStartMs = const Value.absent(),
    this.trimEndMs = const Value.absent(),
    this.trimMode = const Value.absent(),
  });
  DownloadRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String url,
    required String platform,
    required String title,
    this.thumbnailUrl = const Value.absent(),
    this.filePath = const Value.absent(),
    required String formatLabel,
    this.sizeBytes = const Value.absent(),
    required String status,
    this.errorCode = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.videoFormatId = const Value.absent(),
    this.audioFormatId = const Value.absent(),
    this.container = const Value.absent(),
    this.audioCodec = const Value.absent(),
    this.trimStartMs = const Value.absent(),
    this.trimEndMs = const Value.absent(),
    this.trimMode = const Value.absent(),
  }) : url = Value(url),
       platform = Value(platform),
       title = Value(title),
       formatLabel = Value(formatLabel),
       status = Value(status);
  static Insertable<DownloadRecord> custom({
    Expression<int>? id,
    Expression<String>? url,
    Expression<String>? platform,
    Expression<String>? title,
    Expression<String>? thumbnailUrl,
    Expression<String>? filePath,
    Expression<String>? formatLabel,
    Expression<int>? sizeBytes,
    Expression<String>? status,
    Expression<String>? errorCode,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? completedAt,
    Expression<String>? videoFormatId,
    Expression<String>? audioFormatId,
    Expression<String>? container,
    Expression<String>? audioCodec,
    Expression<int>? trimStartMs,
    Expression<int>? trimEndMs,
    Expression<String>? trimMode,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (url != null) 'url': url,
      if (platform != null) 'platform': platform,
      if (title != null) 'title': title,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (filePath != null) 'file_path': filePath,
      if (formatLabel != null) 'format_label': formatLabel,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (status != null) 'status': status,
      if (errorCode != null) 'error_code': errorCode,
      if (createdAt != null) 'created_at': createdAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (videoFormatId != null) 'video_format_id': videoFormatId,
      if (audioFormatId != null) 'audio_format_id': audioFormatId,
      if (container != null) 'container': container,
      if (audioCodec != null) 'audio_codec': audioCodec,
      if (trimStartMs != null) 'trim_start_ms': trimStartMs,
      if (trimEndMs != null) 'trim_end_ms': trimEndMs,
      if (trimMode != null) 'trim_mode': trimMode,
    });
  }

  DownloadRecordsCompanion copyWith({
    Value<int>? id,
    Value<String>? url,
    Value<String>? platform,
    Value<String>? title,
    Value<String?>? thumbnailUrl,
    Value<String?>? filePath,
    Value<String>? formatLabel,
    Value<int?>? sizeBytes,
    Value<String>? status,
    Value<String?>? errorCode,
    Value<DateTime>? createdAt,
    Value<DateTime?>? completedAt,
    Value<String?>? videoFormatId,
    Value<String?>? audioFormatId,
    Value<String?>? container,
    Value<String?>? audioCodec,
    Value<int?>? trimStartMs,
    Value<int?>? trimEndMs,
    Value<String?>? trimMode,
  }) {
    return DownloadRecordsCompanion(
      id: id ?? this.id,
      url: url ?? this.url,
      platform: platform ?? this.platform,
      title: title ?? this.title,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      filePath: filePath ?? this.filePath,
      formatLabel: formatLabel ?? this.formatLabel,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      status: status ?? this.status,
      errorCode: errorCode ?? this.errorCode,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      videoFormatId: videoFormatId ?? this.videoFormatId,
      audioFormatId: audioFormatId ?? this.audioFormatId,
      container: container ?? this.container,
      audioCodec: audioCodec ?? this.audioCodec,
      trimStartMs: trimStartMs ?? this.trimStartMs,
      trimEndMs: trimEndMs ?? this.trimEndMs,
      trimMode: trimMode ?? this.trimMode,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (platform.present) {
      map['platform'] = Variable<String>(platform.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (thumbnailUrl.present) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (formatLabel.present) {
      map['format_label'] = Variable<String>(formatLabel.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (errorCode.present) {
      map['error_code'] = Variable<String>(errorCode.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (videoFormatId.present) {
      map['video_format_id'] = Variable<String>(videoFormatId.value);
    }
    if (audioFormatId.present) {
      map['audio_format_id'] = Variable<String>(audioFormatId.value);
    }
    if (container.present) {
      map['container'] = Variable<String>(container.value);
    }
    if (audioCodec.present) {
      map['audio_codec'] = Variable<String>(audioCodec.value);
    }
    if (trimStartMs.present) {
      map['trim_start_ms'] = Variable<int>(trimStartMs.value);
    }
    if (trimEndMs.present) {
      map['trim_end_ms'] = Variable<int>(trimEndMs.value);
    }
    if (trimMode.present) {
      map['trim_mode'] = Variable<String>(trimMode.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadRecordsCompanion(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('platform: $platform, ')
          ..write('title: $title, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('filePath: $filePath, ')
          ..write('formatLabel: $formatLabel, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('status: $status, ')
          ..write('errorCode: $errorCode, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('videoFormatId: $videoFormatId, ')
          ..write('audioFormatId: $audioFormatId, ')
          ..write('container: $container, ')
          ..write('audioCodec: $audioCodec, ')
          ..write('trimStartMs: $trimStartMs, ')
          ..write('trimEndMs: $trimEndMs, ')
          ..write('trimMode: $trimMode')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSetting copyWith({String? key, String? value}) =>
      AppSetting(key: key ?? this.key, value: value ?? this.value);
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DownloadRecordsTable downloadRecords = $DownloadRecordsTable(
    this,
  );
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    downloadRecords,
    appSettings,
  ];
}

typedef $$DownloadRecordsTableCreateCompanionBuilder =
    DownloadRecordsCompanion Function({
      Value<int> id,
      required String url,
      required String platform,
      required String title,
      Value<String?> thumbnailUrl,
      Value<String?> filePath,
      required String formatLabel,
      Value<int?> sizeBytes,
      required String status,
      Value<String?> errorCode,
      Value<DateTime> createdAt,
      Value<DateTime?> completedAt,
      Value<String?> videoFormatId,
      Value<String?> audioFormatId,
      Value<String?> container,
      Value<String?> audioCodec,
      Value<int?> trimStartMs,
      Value<int?> trimEndMs,
      Value<String?> trimMode,
    });
typedef $$DownloadRecordsTableUpdateCompanionBuilder =
    DownloadRecordsCompanion Function({
      Value<int> id,
      Value<String> url,
      Value<String> platform,
      Value<String> title,
      Value<String?> thumbnailUrl,
      Value<String?> filePath,
      Value<String> formatLabel,
      Value<int?> sizeBytes,
      Value<String> status,
      Value<String?> errorCode,
      Value<DateTime> createdAt,
      Value<DateTime?> completedAt,
      Value<String?> videoFormatId,
      Value<String?> audioFormatId,
      Value<String?> container,
      Value<String?> audioCodec,
      Value<int?> trimStartMs,
      Value<int?> trimEndMs,
      Value<String?> trimMode,
    });

class $$DownloadRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $DownloadRecordsTable> {
  $$DownloadRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get formatLabel => $composableBuilder(
    column: $table.formatLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorCode => $composableBuilder(
    column: $table.errorCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get videoFormatId => $composableBuilder(
    column: $table.videoFormatId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioFormatId => $composableBuilder(
    column: $table.audioFormatId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get container => $composableBuilder(
    column: $table.container,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioCodec => $composableBuilder(
    column: $table.audioCodec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get trimStartMs => $composableBuilder(
    column: $table.trimStartMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get trimEndMs => $composableBuilder(
    column: $table.trimEndMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trimMode => $composableBuilder(
    column: $table.trimMode,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DownloadRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $DownloadRecordsTable> {
  $$DownloadRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get formatLabel => $composableBuilder(
    column: $table.formatLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorCode => $composableBuilder(
    column: $table.errorCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get videoFormatId => $composableBuilder(
    column: $table.videoFormatId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioFormatId => $composableBuilder(
    column: $table.audioFormatId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get container => $composableBuilder(
    column: $table.container,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioCodec => $composableBuilder(
    column: $table.audioCodec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get trimStartMs => $composableBuilder(
    column: $table.trimStartMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get trimEndMs => $composableBuilder(
    column: $table.trimEndMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trimMode => $composableBuilder(
    column: $table.trimMode,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DownloadRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DownloadRecordsTable> {
  $$DownloadRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get platform =>
      $composableBuilder(column: $table.platform, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get formatLabel => $composableBuilder(
    column: $table.formatLabel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get errorCode =>
      $composableBuilder(column: $table.errorCode, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get videoFormatId => $composableBuilder(
    column: $table.videoFormatId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get audioFormatId => $composableBuilder(
    column: $table.audioFormatId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get container =>
      $composableBuilder(column: $table.container, builder: (column) => column);

  GeneratedColumn<String> get audioCodec => $composableBuilder(
    column: $table.audioCodec,
    builder: (column) => column,
  );

  GeneratedColumn<int> get trimStartMs => $composableBuilder(
    column: $table.trimStartMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get trimEndMs =>
      $composableBuilder(column: $table.trimEndMs, builder: (column) => column);

  GeneratedColumn<String> get trimMode =>
      $composableBuilder(column: $table.trimMode, builder: (column) => column);
}

class $$DownloadRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DownloadRecordsTable,
          DownloadRecord,
          $$DownloadRecordsTableFilterComposer,
          $$DownloadRecordsTableOrderingComposer,
          $$DownloadRecordsTableAnnotationComposer,
          $$DownloadRecordsTableCreateCompanionBuilder,
          $$DownloadRecordsTableUpdateCompanionBuilder,
          (
            DownloadRecord,
            BaseReferences<
              _$AppDatabase,
              $DownloadRecordsTable,
              DownloadRecord
            >,
          ),
          DownloadRecord,
          PrefetchHooks Function()
        > {
  $$DownloadRecordsTableTableManager(
    _$AppDatabase db,
    $DownloadRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String> platform = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> thumbnailUrl = const Value.absent(),
                Value<String?> filePath = const Value.absent(),
                Value<String> formatLabel = const Value.absent(),
                Value<int?> sizeBytes = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> errorCode = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String?> videoFormatId = const Value.absent(),
                Value<String?> audioFormatId = const Value.absent(),
                Value<String?> container = const Value.absent(),
                Value<String?> audioCodec = const Value.absent(),
                Value<int?> trimStartMs = const Value.absent(),
                Value<int?> trimEndMs = const Value.absent(),
                Value<String?> trimMode = const Value.absent(),
              }) => DownloadRecordsCompanion(
                id: id,
                url: url,
                platform: platform,
                title: title,
                thumbnailUrl: thumbnailUrl,
                filePath: filePath,
                formatLabel: formatLabel,
                sizeBytes: sizeBytes,
                status: status,
                errorCode: errorCode,
                createdAt: createdAt,
                completedAt: completedAt,
                videoFormatId: videoFormatId,
                audioFormatId: audioFormatId,
                container: container,
                audioCodec: audioCodec,
                trimStartMs: trimStartMs,
                trimEndMs: trimEndMs,
                trimMode: trimMode,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String url,
                required String platform,
                required String title,
                Value<String?> thumbnailUrl = const Value.absent(),
                Value<String?> filePath = const Value.absent(),
                required String formatLabel,
                Value<int?> sizeBytes = const Value.absent(),
                required String status,
                Value<String?> errorCode = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String?> videoFormatId = const Value.absent(),
                Value<String?> audioFormatId = const Value.absent(),
                Value<String?> container = const Value.absent(),
                Value<String?> audioCodec = const Value.absent(),
                Value<int?> trimStartMs = const Value.absent(),
                Value<int?> trimEndMs = const Value.absent(),
                Value<String?> trimMode = const Value.absent(),
              }) => DownloadRecordsCompanion.insert(
                id: id,
                url: url,
                platform: platform,
                title: title,
                thumbnailUrl: thumbnailUrl,
                filePath: filePath,
                formatLabel: formatLabel,
                sizeBytes: sizeBytes,
                status: status,
                errorCode: errorCode,
                createdAt: createdAt,
                completedAt: completedAt,
                videoFormatId: videoFormatId,
                audioFormatId: audioFormatId,
                container: container,
                audioCodec: audioCodec,
                trimStartMs: trimStartMs,
                trimEndMs: trimEndMs,
                trimMode: trimMode,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DownloadRecordsTable, DownloadRecord>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $DownloadRecordsTable,
                    DownloadRecord
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DownloadRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DownloadRecordsTable,
      DownloadRecord,
      $$DownloadRecordsTableFilterComposer,
      $$DownloadRecordsTableOrderingComposer,
      $$DownloadRecordsTableAnnotationComposer,
      $$DownloadRecordsTableCreateCompanionBuilder,
      $$DownloadRecordsTableUpdateCompanionBuilder,
      (
        DownloadRecord,
        BaseReferences<_$AppDatabase, $DownloadRecordsTable, DownloadRecord>,
      ),
      DownloadRecord,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, AppSetting>(table),
                  BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DownloadRecordsTableTableManager get downloadRecords =>
      $$DownloadRecordsTableTableManager(_db, _db.downloadRecords);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
