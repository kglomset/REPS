package com.reps.repository;

import com.reps.entity.Movement;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface MovementRepository extends JpaRepository<Movement, Long> {

    /**
     * Only one List-typed ("bag") association is join-fetched here.
     * {@code muscles} and {@code equipmentOptions} are BOTH bags (plain
     * {@code List}, no {@code @OrderColumn}), and Hibernate does not
     * deduplicate elements *within* a bag the way it dedupes root entities
     * via {@code DISTINCT} — join-fetching two bags in one query makes each
     * row of the muscles x equipmentOptions cross product append to both
     * collections, so every movement's muscle chips (and equipment chips)
     * came back duplicated once per equipment option (reported as "chips
     * duplicated by the number of variations").
     *
     * equipmentOptions is still eager (see the entity), so Hibernate loads
     * it with its own follow-up select per movement instead - no N+1 blow-up
     * at this list size, and no duplication.
     */
    @Query("SELECT DISTINCT m FROM Movement m " +
           "LEFT JOIN FETCH m.muscles em LEFT JOIN FETCH em.muscleGroup " +
           "WHERE m.createdBy IS NULL OR m.createdBy.id = :userId")
    List<Movement> findAllAvailableForUser(Long userId);

    Optional<Movement> findByNameIgnoreCase(String name);
}
