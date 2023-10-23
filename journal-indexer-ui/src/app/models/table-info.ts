import {Record} from "./record";
import {Filter} from "./filter";

export interface TableInfo {
  page: number

  recordPerPage: number

  firstID: number

  lastID: number

  records: Record[]

  filter: Filter

  endOfData: boolean

  state?: string

  showRestoreButton?: boolean

  showExportButton?: boolean

}
