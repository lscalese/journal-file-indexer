import {FilterProperties} from "./filter-properties";

export class Filter {
  Address?: FilterProperties;
  DatabaseName?: FilterProperties;
  GlobalName?: FilterProperties;
  File?: FilterProperties;
  InTransaction?: FilterProperties;
  NewValue?: FilterProperties;
  OldValue?: FilterProperties;
  ProcessID?: FilterProperties;
  Subscripts?: Array<FilterProperties>;
  TimeStamp?: FilterProperties;
  Type?: FilterProperties;
  SubscriptsSize?: FilterProperties;
}
