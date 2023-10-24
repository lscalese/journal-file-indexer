export interface IrisError {
  errors?: {
    code?: string,
    domain?: string,
    id?: string,
    params?: string[]
  }[],
  summary?: string
}
