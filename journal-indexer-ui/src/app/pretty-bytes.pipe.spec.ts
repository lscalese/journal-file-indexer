import { PrettyBytesPipe } from './pretty-bytes.pipe';

describe('PrettyBytesPipe', () => {
  it('create an instance', () => {
    const pipe = new PrettyBytesPipe();
    expect(pipe).toBeTruthy();
  });
});
