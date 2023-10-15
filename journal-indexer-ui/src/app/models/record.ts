export interface Record {
    file: number

    address: number

    type: string

    prevAddress: number

    nextAddress: number

    timestamp: string

    inTransaction: boolean

    processID: number

    databaseName: string

    globalNode: string

    formattedOldValue: string

    formattedNewValue: string

    existsNewValue: boolean

    existsOldValue: boolean

    position: number
}
