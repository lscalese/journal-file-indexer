import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ShowJournalComponent } from './show-journal.component';

describe('ShowJournalComponent', () => {
  let component: ShowJournalComponent;
  let fixture: ComponentFixture<ShowJournalComponent>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      declarations: [ShowJournalComponent]
    });
    fixture = TestBed.createComponent(ShowJournalComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
