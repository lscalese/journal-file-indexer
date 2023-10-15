import { TestBed } from '@angular/core/testing';

import { TempStoreService } from './temp-store.service';

describe('TempStoreService', () => {
  let service: TempStoreService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(TempStoreService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
