
;; title: NarrativeVote
;; version: 1.0.0
;; summary: A collaborative storytelling platform for plot development and character decisions
;; description: Smart contract enabling users to create stories, develop characters, and vote on plot decisions

;; constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-STORY-NOT-FOUND (err u101))
(define-constant ERR-CHARACTER-NOT-FOUND (err u102))
(define-constant ERR-DECISION-NOT-FOUND (err u103))
(define-constant ERR-ALREADY-VOTED (err u104))
(define-constant ERR-VOTING-ENDED (err u105))
(define-constant ERR-INSUFFICIENT-VOTES (err u106))

;; data vars
(define-data-var story-id-nonce uint u0)
(define-data-var character-id-nonce uint u0)
(define-data-var decision-id-nonce uint u0)

;; data maps
(define-map stories
  uint
  {
    creator: principal,
    title: (string-ascii 100),
    description: (string-ascii 500),
    genre: (string-ascii 50),
    created-at: uint,
    is-active: bool
  }
)

(define-map characters
  uint
  {
    story-id: uint,
    creator: principal,
    name: (string-ascii 50),
    description: (string-ascii 300),
    traits: (string-ascii 200),
    created-at: uint
  }
)

(define-map plot-decisions
  uint
  {
    story-id: uint,
    creator: principal,
    title: (string-ascii 100),
    description: (string-ascii 300),
    option-a: (string-ascii 200),
    option-b: (string-ascii 200),
    votes-a: uint,
    votes-b: uint,
    voting-ends: uint,
    is-resolved: bool,
    winning-option: (optional (string-ascii 1))
  }
)

(define-map user-votes
  {decision-id: uint, voter: principal}
  {option: (string-ascii 1), voted-at: uint}
)

(define-map story-collaborators
  {story-id: uint, collaborator: principal}
  {role: (string-ascii 20), added-at: uint}
)

;; public functions

;; Create a new story
(define-public (create-story (title (string-ascii 100)) (description (string-ascii 500)) (genre (string-ascii 50)))
  (let
    (
      (new-story-id (+ (var-get story-id-nonce) u1))
    )
    (map-set stories new-story-id {
      creator: tx-sender,
      title: title,
      description: description,
      genre: genre,
      created-at: block-height,
      is-active: true
    })
    (var-set story-id-nonce new-story-id)
    (ok new-story-id)
  )
)

;; Add a collaborator to a story
(define-public (add-collaborator (story-id uint) (collaborator principal) (role (string-ascii 20)))
  (match (map-get? stories story-id)
    story-data
    (if (is-eq (get creator story-data) tx-sender)
      (begin
        (map-set story-collaborators {story-id: story-id, collaborator: collaborator} {
          role: role,
          added-at: block-height
        })
        (ok true)
      )
      ERR-NOT-AUTHORIZED
    )
    ERR-STORY-NOT-FOUND
  )
)

;; Create a character for a story
(define-public (create-character (story-id uint) (name (string-ascii 50)) (description (string-ascii 300)) (traits (string-ascii 200)))
  (match (map-get? stories story-id)
    story-data
    (if (or
          (is-eq (get creator story-data) tx-sender)
          (is-some (map-get? story-collaborators {story-id: story-id, collaborator: tx-sender}))
        )
      (let
        (
          (new-character-id (+ (var-get character-id-nonce) u1))
        )
        (map-set characters new-character-id {
          story-id: story-id,
          creator: tx-sender,
          name: name,
          description: description,
          traits: traits,
          created-at: block-height
        })
        (var-set character-id-nonce new-character-id)
        (ok new-character-id)
      )
      ERR-NOT-AUTHORIZED
    )
    ERR-STORY-NOT-FOUND
  )
)

;; Create a plot decision for voting
(define-public (create-plot-decision
    (story-id uint)
    (title (string-ascii 100))
    (description (string-ascii 300))
    (option-a (string-ascii 200))
    (option-b (string-ascii 200))
    (voting-duration uint)
  )
  (match (map-get? stories story-id)
    story-data
    (if (or
          (is-eq (get creator story-data) tx-sender)
          (is-some (map-get? story-collaborators {story-id: story-id, collaborator: tx-sender}))
        )
      (let
        (
          (new-decision-id (+ (var-get decision-id-nonce) u1))
          (voting-ends (+ block-height voting-duration))
        )
        (map-set plot-decisions new-decision-id {
          story-id: story-id,
          creator: tx-sender,
          title: title,
          description: description,
          option-a: option-a,
          option-b: option-b,
          votes-a: u0,
          votes-b: u0,
          voting-ends: voting-ends,
          is-resolved: false,
          winning-option: none
        })
        (var-set decision-id-nonce new-decision-id)
        (ok new-decision-id)
      )
      ERR-NOT-AUTHORIZED
    )
    ERR-STORY-NOT-FOUND
  )
)

;; Vote on a plot decision
(define-public (vote-on-decision (decision-id uint) (option (string-ascii 1)))
  (match (map-get? plot-decisions decision-id)
    decision-data
    (if (< block-height (get voting-ends decision-data))
      (if (is-none (map-get? user-votes {decision-id: decision-id, voter: tx-sender}))
        (if (or (is-eq option "a") (is-eq option "b"))
          (begin
            (map-set user-votes {decision-id: decision-id, voter: tx-sender} {
              option: option,
              voted-at: block-height
            })
            (if (is-eq option "a")
              (map-set plot-decisions decision-id (merge decision-data {votes-a: (+ (get votes-a decision-data) u1)}))
              (map-set plot-decisions decision-id (merge decision-data {votes-b: (+ (get votes-b decision-data) u1)}))
            )
            (ok true)
          )
          (err u107) ;; Invalid option
        )
        ERR-ALREADY-VOTED
      )
      ERR-VOTING-ENDED
    )
    ERR-DECISION-NOT-FOUND
  )
)

;; Resolve a plot decision (can be called after voting period ends)
(define-public (resolve-decision (decision-id uint))
  (match (map-get? plot-decisions decision-id)
    decision-data
    (if (>= block-height (get voting-ends decision-data))
      (if (not (get is-resolved decision-data))
        (let
          (
            (votes-a (get votes-a decision-data))
            (votes-b (get votes-b decision-data))
            (winning-option (if (> votes-a votes-b) "a" "b"))
          )
          (map-set plot-decisions decision-id (merge decision-data {
            is-resolved: true,
            winning-option: (some winning-option)
          }))
          (ok winning-option)
        )
        (ok (unwrap-panic (get winning-option decision-data)))
      )
      ERR-VOTING-ENDED
    )
    ERR-DECISION-NOT-FOUND
  )
)

;; read only functions

;; Get story details
(define-read-only (get-story (story-id uint))
  (map-get? stories story-id)
)

;; Get character details
(define-read-only (get-character (character-id uint))
  (map-get? characters character-id)
)

;; Get plot decision details
(define-read-only (get-plot-decision (decision-id uint))
  (map-get? plot-decisions decision-id)
)

;; Check if user has voted on a decision
(define-read-only (has-voted (decision-id uint) (voter principal))
  (is-some (map-get? user-votes {decision-id: decision-id, voter: voter}))
)

;; Get user's vote on a decision
(define-read-only (get-user-vote (decision-id uint) (voter principal))
  (map-get? user-votes {decision-id: decision-id, voter: voter})
)

;; Check if user is a collaborator on a story
(define-read-only (is-collaborator (story-id uint) (user principal))
  (is-some (map-get? story-collaborators {story-id: story-id, collaborator: user}))
)

;; Get current nonce values
(define-read-only (get-story-count)
  (var-get story-id-nonce)
)

(define-read-only (get-character-count)
  (var-get character-id-nonce)
)

(define-read-only (get-decision-count)
  (var-get decision-id-nonce)
)

