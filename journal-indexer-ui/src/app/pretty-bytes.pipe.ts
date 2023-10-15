import { Pipe, PipeTransform } from '@angular/core';
import prettyBytes from "pretty-bytes";

@Pipe({
  name: 'PrettyBytes'
})
export class PrettyBytesPipe implements PipeTransform {

  transform(value: number): string {
    return prettyBytes(value);
  }

}
