import { ComponentFixture, TestBed } from '@angular/core/testing';

import { JournalFormComponent } from './journal-form.component';

describe('JournalFormComponent', () => {
  let component: JournalFormComponent;
  let fixture: ComponentFixture<JournalFormComponent>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      declarations: [JournalFormComponent]
    });
    fixture = TestBed.createComponent(JournalFormComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
