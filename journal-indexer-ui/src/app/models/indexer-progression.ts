export interface IndexerProgression {
  Status?: string;
  Action?: string;
  FileExists?: boolean;
  IsValid?: boolean;
  Load?: string;
  Flush?: string;
  BuildIndices?: string;
  Tune?: string;
  JournalFile?: string;
  Message?: string;
  MessageType?: string;
}
