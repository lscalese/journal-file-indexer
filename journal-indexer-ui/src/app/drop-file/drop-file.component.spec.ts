import { ComponentFixture, TestBed } from '@angular/core/testing';

import { DropFileComponent } from './drop-file.component';

describe('DropFileComponent', () => {
  let component: DropFileComponent;
  let fixture: ComponentFixture<DropFileComponent>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      declarations: [DropFileComponent]
    });
    fixture = TestBed.createComponent(DropFileComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
