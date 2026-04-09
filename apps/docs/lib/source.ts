import { docs, legal as legalSource } from '@/.source'
import { loader } from 'fumadocs-core/source'

export const source = loader({
  baseUrl: '/docs',
  source: docs.toFumadocsSource(),
})

export const legal = loader({
  baseUrl: '/legal',
  source: legalSource.toFumadocsSource(),
})
