import { ComponentFixture, TestBed } from '@angular/core/testing';

import { JournalProgressionComponent } from './journal-progression.component';

describe('JournalProgressionComponent', () => {
  let component: JournalProgressionComponent;
  let fixture: ComponentFixture<JournalProgressionComponent>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      declarations: [JournalProgressionComponent]
    });
    fixture = TestBed.createComponent(JournalProgressionComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
