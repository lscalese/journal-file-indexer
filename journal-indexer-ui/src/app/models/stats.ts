import {StatsData} from "./stats-data";
export interface Stats {
  FileId: string;
  UserDefinedName?: string;
  Globals: StatsData [];
  Databases: StatsData [];
  PID: StatsData [];
}
