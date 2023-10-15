import { TestBed } from '@angular/core/testing';

import { JournalProgressionService } from './journal-progression.service';

describe('JournalProgressionService', () => {
  let service: JournalProgressionService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(JournalProgressionService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
