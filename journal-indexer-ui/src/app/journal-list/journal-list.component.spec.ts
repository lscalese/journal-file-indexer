import { ComponentFixture, TestBed } from '@angular/core/testing';

import { JournalListComponent } from './journal-list.component';

describe('JournalListComponent', () => {
  let component: JournalListComponent;
  let fixture: ComponentFixture<JournalListComponent>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      declarations: [JournalListComponent]
    });
    fixture = TestBed.createComponent(JournalListComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
