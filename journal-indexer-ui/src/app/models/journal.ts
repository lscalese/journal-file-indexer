/// Model to represent an indexed journal file.
export interface Journal {

  ID: string;

  /// Path on the journal file on the disk
  Name: string;

  /// Name of the journal file basically yyyymmdd.xxx
  UserDefinedName: string;

  /// Address of the first record in the journal file.
  FirstRecord: number;

  /// Address of the last record in the journal file.
  LastRecord: number;

  FirstRecordTS: string;

  LastRecordTS: string;

}
