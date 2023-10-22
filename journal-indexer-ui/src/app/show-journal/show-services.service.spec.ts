import { TestBed } from '@angular/core/testing';

import { ShowServices } from './show-services.service';

describe('ShowServicesService', () => {
  let service: ShowServices;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(ShowServices);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
