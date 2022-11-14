export class ModelVersionResponseDto {
  id: string;

  versionName: string;

  logFilePath: string;

  logFileBCHash: string;

  noteBookVersion: string;

  testDataSetsUrl: string;

  testDatasetBCHash: string;

  trainDataSetsUrl: string;

  trainDatasetBCHash: string;

  aiModelUrl: string;

  aiModelBCHash: string;

  codeVersion: string;

  codeRepo: string;

  comment: string;

  versionStatus: string;

  status: boolean;

  project: string;

  recordDate: string;

  entryUser: string;

  creatorMSP: string;
}
