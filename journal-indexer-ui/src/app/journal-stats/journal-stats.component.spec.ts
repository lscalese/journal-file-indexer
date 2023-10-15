import { ComponentFixture, TestBed } from '@angular/core/testing';

import { JournalStatsComponent } from './journal-stats.component';

describe('JournalStatsComponent', () => {
  let component: JournalStatsComponent;
  let fixture: ComponentFixture<JournalStatsComponent>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      declarations: [JournalStatsComponent]
    });
    fixture = TestBed.createComponent(JournalStatsComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
