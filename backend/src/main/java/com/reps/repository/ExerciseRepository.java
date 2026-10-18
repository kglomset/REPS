package com.reps.repository;

import com.reps.entity.Exercise;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;

public interface ExerciseRepository extends JpaRepository<Exercise, Long> {

    /**
     * Does NOT join-fetch {@code mv.muscles}, even though {@code mv} (the
     * movement) is itself fetched here. {@code muscles} is a List-typed
     * ("bag") collection hanging off Movement, and Movement is a many-to-one
     * shared by every equipment/variation sibling of the same movement - the
     * query's {@code DISTINCT} only dedupes at the Exercise (root) level, not
     * at Movement, so when several sibling exercises share one movement,
     * Hibernate re-appends that movement's muscle rows once per sibling while
     * hydrating the result set. A movement with 3 equipment variants came
     * back with its muscles list tripled for every one of those exercises
     * (and for every *other* exercise that touched the same cached Movement
     * later in the same request - this is what was corrupting the "swap"
     * exercise's muscle chips via ProgressionService.findAlternatives(),
     * which calls this method, even though GET /movements was already
     * fixed).
     *
     * muscles is still FetchType.EAGER on the entity, so Hibernate loads it
     * with its own per-movement follow-up select instead - keyed on the
     * movement's id, so it's loaded (and deduplicated) exactly once no
     * matter how many sibling exercises share that movement.
     */
    @Query("SELECT DISTINCT e FROM Exercise e " +
           "LEFT JOIN FETCH e.movement mv " +
           "LEFT JOIN FETCH e.equipment " +
           "WHERE e.createdBy IS NULL OR e.createdBy.id = :userId")
    List<Exercise> findAllAvailableForUser(Long userId);

    List<Exercise> findByCreatedByIsNull();

    List<Exercise> findByMovementId(Long movementId);
}
