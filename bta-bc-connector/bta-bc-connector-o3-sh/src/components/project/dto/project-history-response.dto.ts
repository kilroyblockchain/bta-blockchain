import { ProjectResponseDto } from './project-response.dto';

export class ProjectHistoryResponseDto {
  txId: string;

  isDeleted: boolean;

  project: ProjectResponseDto;
}
