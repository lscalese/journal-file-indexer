import { TestBed } from '@angular/core/testing';

import { JournalFileService } from './journal-file.service';

describe('JournalFileService', () => {
  let service: JournalFileService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(JournalFileService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
